//
//  OCLStore.m
//  OBJCLucene
//
//  Created by Sean Lynch on 3/30/14.
//
//

#import "OCLStore.h"

#import "OBJCLucene.h"
#include "CLucene.h"

#import "NSString+OCL.h"

#include "BlockFieldSelector.h"
#include "BlockHitCollector.h"


#include <map>
#include <vector>
#include <string>
#include <set>

#include "NumberTools.h"
#include "NumericUtils.h"

#include "MatchAllDocsQuery.h"

#include "NSEntityDescription+OCL.h"
#include "NSPropertyDescription+OCL.h"
#include "NSManagedObject+OCL.h"

using namespace ocl;
using namespace lucene::index;
using namespace lucene::search;
using namespace lucene::analysis;
using namespace lucene::document;
using namespace std;

static NSString *OCLStoreMetadataFileName = @"metadata";
NSString * const OCLStoreType = @"OCLStore";

NSString * const OCLStoreAnalyzerKey = @"analyzer";
NSString * const OCLStoreStandardAnalyzer = @"standard";
NSString * const OCLStoreNoStopStandardAnalyzer = @"nostop";
NSString * const OCLStoreKeywordAnalyzer = @"keyword";

@interface OCLStore () {
    map<NSString *, Analyzer *> _analyzersByEntityName;
}

@property (nonatomic, strong) NSDictionary *entitiesByName;

@property (nonatomic, strong) NSOperationQueue *writeOperationQueue;
@property (nonatomic, strong) NSCache *valuesCache;

@end

@implementation OCLStore

#pragma mark - Initialization

+ (void)initialize {
    [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:OCLStoreType];
}

+ (NSString *)type {
    return OCLStoreType;
}

- (BOOL)loadMetadata:(NSError *__autoreleasing *)error
{
    NSURL *url = [self.URL URLByAppendingPathComponent:OCLStoreMetadataFileName];
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.URL.path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:self.URL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSData *metadataData = [NSData dataWithContentsOfURL:url];
    NSDictionary *dictionary = nil;
    if(metadataData != nil) {
        dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:metadataData];
    }
    if(dictionary == nil) {
        dictionary = @{ NSStoreTypeKey: OCLStoreType, NSStoreUUIDKey: [[NSProcessInfo processInfo] globallyUniqueString] };
        NSError *writeError = nil;
        if(![[NSKeyedArchiver archivedDataWithRootObject:dictionary] writeToURL:url options:NSDataWritingFileProtectionComplete error:&writeError]) {
            if(error != NULL) {
                *error = writeError;
                return NO;
            }
        }
    }
    [self setMetadata:dictionary];
    self.writeOperationQueue = [[NSOperationQueue alloc] init];
    self.writeOperationQueue.maxConcurrentOperationCount = 1;
    __block map<NSString *, Analyzer *> analyzersByEntityName;
    self.valuesCache = [[NSCache alloc] init];
    NSMutableDictionary *entitiesByName = [[NSMutableDictionary alloc] init];
    [[self.persistentStoreCoordinator.managedObjectModel entitiesForConfiguration:self.configurationName] enumerateObjectsUsingBlock:^(NSEntityDescription *entity, NSUInteger index, BOOL *stop) {
        PerFieldAnalyzerWrapper *analyzer = _CLNEW PerFieldAnalyzerWrapper(_CLNEW KeywordAnalyzer());
        [entitiesByName setObject:entity forKey:entity.name];
        [entity.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, NSAttributeDescription *attribute, BOOL *stop) {
            NSString *analyzerType = attribute.userInfo[OCLStoreAnalyzerKey];
            if(analyzerType == nil || [analyzerType isEqualToString:OCLStoreStandardAnalyzer]) {
                if(attribute.attributeType == NSStringAttributeType) {
                    analyzer->addAnalyzer([attribute.name toTCHAR], _CLNEW standard::StandardAnalyzer());
                }
            } else if([analyzerType isEqualToString:OCLStoreNoStopStandardAnalyzer]) {
                const TCHAR *emptyStopWords[1] = { NULL };
                analyzer->addAnalyzer([attribute.name toTCHAR], _CLNEW standard::StandardAnalyzer(emptyStopWords));
            } else {
                analyzer->addAnalyzer([attribute.name toTCHAR], _CLNEW KeywordAnalyzer());
            }
        }];
        analyzersByEntityName[entity.name] = analyzer;
    }];
    _analyzersByEntityName = analyzersByEntityName;
    self.entitiesByName = entitiesByName;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    return YES;
}

- (void)dealloc
{
    for(auto itr = _analyzersByEntityName.begin(); itr != _analyzersByEntityName.end(); ++itr) {
        _CLVDELETE(itr->second);
    }
}

#pragma mark - Request execution

- (id)executeRequest:(NSPersistentStoreRequest *)request withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    switch (request.requestType) {
        case NSFetchRequestType:
            return [self executeFetchRequest:(NSFetchRequest *)request withContext:context error:error];
            break;
        case NSSaveRequestType:
            return [self executeSaveRequest:(NSSaveChangesRequest *)request withContext:context error:error];
            break;
    }
    return nil;
}

- (NSArray *)executeFetchRequest:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    IndexReader *indexReader = [self indexReaderForEntity:request.entity];
    if(indexReader == NULL) {
        return @[];
    }
    IndexSearcher *indexSearcher = _CLNEW IndexSearcher(indexReader);
    Query *query = [self queryForRequest:request indexReader:indexReader];
    if(query == NULL) {
        indexReader->close();
        _CLVDELETE(indexSearcher);
        _CLVDELETE(indexReader);
        return @[];
    }
    FieldSelectorBlock selectorBlock = nil;
    HitCollectorBlock hitCollectorBlock = nil;
    NSArray *(^parseResults)(void) = ^(void) {
        return @[];
    };
    __block NSUInteger count = 0;
    if(request.resultType == NSCountResultType) {
        selectorBlock = ^(const TCHAR *fieldName) {
            return FieldSelector::SIZE_AND_BREAK;
        };
        hitCollectorBlock = ^(int32_t doc, float_t score) {
            ++count;
        };
        parseResults = ^(void) {
            return @[ @(count) ];
        };
    } else {
        NSMutableArray *documentResults = [[NSMutableArray alloc] init];
        NSMutableArray *results = [[NSMutableArray alloc] init];
        __block set<wstring> fields;
        __block map<wstring, NSAttributeType> fieldTypes;
        wstring idString = [request.entity.attributeNameForObjectId toTCHAR];
        fields.insert(idString);
        fieldTypes[idString] = NSStringAttributeType;
        [request.sortDescriptors enumerateObjectsUsingBlock:^(NSSortDescriptor *sortDescriptor, NSUInteger index, BOOL *stop) {
            wstring fieldName = [sortDescriptor.key toTCHAR];
            fields.insert(wstring(fieldName));
            NSAttributeDescription *attribute = request.entity.attributesByName[sortDescriptor.key];
            if(attribute != nil) {
                fieldTypes[fieldName] = attribute.attributeType;
            } else {
                fieldTypes[fieldName] = NSStringAttributeType;
            }
        }];
        if(request.resultType == NSDictionaryResultType) {
            [request.propertiesToFetch enumerateObjectsUsingBlock:^(id property, NSUInteger index, BOOL *stop) {
                if([property isKindOfClass:[NSAttributeDescription class]]) {
                    NSAttributeDescription *attribute = property;
                    wstring fieldName = [attribute.name toTCHAR];
                    fields.insert(fieldName);
                    fieldTypes[fieldName] = attribute.attributeType;
                }
            }];
        }
        selectorBlock = ^(const TCHAR *fieldName) {
            if(fields.find(fieldName) != fields.end()) {
                if(fields.size() == 1) {
                    return FieldSelector::LOAD_AND_BREAK;
                } else {
                    return FieldSelector::LOAD;
                }
            }
            return FieldSelector::NO_LOAD;
        };
        BlockFieldSelector selector = BlockFieldSelector(selectorBlock);
        hitCollectorBlock = ^(int32_t doc, float_t score) {
            Document document;
            indexReader->document(doc, document, &selector);
            NSMutableDictionary *documentResult = [NSMutableDictionary dictionary];
            for(Field *field: *document.getFields()) {
                NSString *fieldName = [NSString stringFromTCHAR:field->name()];
                id fieldResult = documentResult[fieldName];
                id fieldValue = [self luceneValue:field->stringValue() type:fieldTypes[field->name()]];
                NSRelationshipDescription *relationship = request.entity.relationshipsByName[fieldName];
                if(relationship != nil) {
                    fieldValue = [self newObjectIDForEntity:relationship.entity referenceObject:fieldValue];
                }
                if(fieldResult == nil) {
                    documentResult[fieldName] = fieldValue;
                } else {
                    if([fieldResult isKindOfClass:[NSMutableArray class]]) {
                        [(NSMutableArray *)fieldResult addObject:fieldValue];
                    } else {
                        NSMutableArray *newFieldResult = [NSMutableArray arrayWithObject:fieldResult];
                        [newFieldResult addObject:fieldValue];
                        documentResult[fieldName] = newFieldResult;
                    }
                }
            }
            NSUInteger index = [documentResults indexOfObject:documentResult inSortedRange:NSMakeRange(0, documentResults.count) options:NSBinarySearchingInsertionIndex usingComparator:^(NSDictionary *obj1, NSDictionary *obj2) {
                for(NSSortDescriptor *sortDescriptor in request.sortDescriptors) {
                    NSComparisonResult  result = NSOrderedSame;
                    NSString *keyPath = sortDescriptor.key;
                    id key1 = [obj1 valueForKeyPath:keyPath];
                    id key2 = [obj2 valueForKeyPath:keyPath];
                    if(!sortDescriptor.ascending) {
                        id tmp = key1;
                        key1 = key2;
                        key2 = tmp;
                    }
                    result = [key1 compare:key2];
                    if(result != NSOrderedSame) {
                        return result;
                    }
                }
                id _id1 = obj1[request.entity.attributeNameForObjectId];
                id _id2 = obj2[request.entity.attributeNameForObjectId];
                return [_id1 compare:_id2];
            }];
            [documentResults insertObject:documentResult atIndex:index];
            switch (request.resultType) {
                case NSManagedObjectIDResultType:
                    [results insertObject:[self newObjectIDForEntity:request.entity referenceObject:documentResult[request.entity.attributeNameForObjectId]] atIndex:index];
                    break;
                    
                case NSManagedObjectResultType:
                    [results insertObject:[context objectWithID:[self newObjectIDForEntity:request.entity referenceObject:documentResult[request.entity.attributeNameForObjectId]]] atIndex:index];
                    break;
                    
                default:
                    [results insertObject:documentResult atIndex:index];
                    break;
            }
        };
        parseResults = ^(void) {
            return results;
        };
    }

    BlockHitCollector hitCollector = BlockHitCollector(hitCollectorBlock);
    indexSearcher->_search(query, NULL, &hitCollector);
    _CLVDELETE(query);
    indexReader->close();
    _CLVDELETE(indexSearcher);
    _CLVDELETE(indexReader);
    return parseResults();
}

- (void)managedObjectContextDidSave:(NSNotification *)notification
{
    NSMutableSet *insertedObjects = [NSMutableSet set];
    NSMutableSet *updateObjects = [NSMutableSet set];
    NSMutableSet *deletedObjects = [NSMutableSet set];
    NSManagedObjectContext *managedObjectContext = notification.object;
    NSManagedObject *(^copyManagedObject)(NSManagedObject *) = ^(NSManagedObject *object) {
        if(object.objectID.persistentStore == self || object.managedObjectContext.persistentStoreCoordinator != self.persistentStoreCoordinator) {
            return (NSManagedObject *)nil;
        }
        if(self.entitiesByName[object.entity.name] == nil) {
            return (NSManagedObject *)nil;
        }
        NSManagedObject *copiedObject = [[NSManagedObject alloc] initWithEntity:object.entity insertIntoManagedObjectContext:managedObjectContext];
        [object.entity.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, NSAttributeDescription *attribute, BOOL *stop) {
            id value = [object valueForKey:attributeName];
            if(value != nil) {
                [copiedObject setValue:value forKey:attributeName];
            }
        }];
        [managedObjectContext assignObject:copiedObject toPersistentStore:self];
        return copiedObject;
    };
    [(NSSet *)notification.userInfo[NSInsertedObjectsKey] enumerateObjectsUsingBlock:^(NSManagedObject *object, BOOL *stop) {
        NSManagedObject *copiedObject = copyManagedObject(object);
        if(copiedObject != nil) {
            [insertedObjects addObject:copiedObject];
        }
    }];

   [(NSSet *)notification.userInfo[NSUpdatedObjectsKey] enumerateObjectsUsingBlock:^(NSManagedObject *object, BOOL *stop) {
        NSManagedObject *copiedObject = copyManagedObject(object);
        if(copiedObject != nil) {
            [insertedObjects addObject:copiedObject];
        }
    }];

   [(NSSet *)notification.userInfo[NSDeletedObjectsKey] enumerateObjectsUsingBlock:^(NSManagedObject *object, BOOL *stop) {
        NSManagedObject *copiedObject = copyManagedObject(object);
        if(copiedObject != nil) {
            [insertedObjects addObject:copiedObject];
        }
    }];
    if(insertedObjects.count > 0 || updateObjects.count > 0 || deletedObjects.count > 0) {
        [self executeSaveRequest:[[NSSaveChangesRequest alloc] initWithInsertedObjects:insertedObjects updatedObjects:updateObjects deletedObjects:deletedObjects lockedObjects:nil] withContext:notification.object error:nil];
    }
}

- (NSArray *)executeSaveRequest:(NSSaveChangesRequest *)request withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.writeOperationQueue addOperationWithBlock:^(void) {
        map<string, IndexReader *> *indexReaders = new map<string, IndexReader *>();
        map<string, IndexWriter *> *indexWriters = new map<string, IndexWriter *>();

//        NSMutableDictionary *indexReaders = [NSMutableDictionary dictionary];
        void (^removeDocumentsBlock)(NSManagedObject *, BOOL *stop) = ^(NSManagedObject *object, BOOL *stop) {
            const string entityString = string([object.entity.name cStringUsingEncoding:NSUTF8StringEncoding]);
            map<string, IndexReader *>::const_iterator it = indexReaders->find(entityString);
            IndexReader *indexReader = NULL;
            if(it != indexReaders->end()) {
                indexReader = it->second;
            }
            if(indexReader == NULL) {
                indexReader = [self indexReaderForEntity:object.entity];
            }
            if(indexReader == NULL) {
                return;
            }
            indexReader->deleteDocuments(new Term([object.entity.attributeNameForObjectId toTCHAR], [object.oclId toTCHAR], true));
            if(it == indexReaders->end()) {
                indexReaders->insert(pair<string, IndexReader *>(entityString, indexReader));
            }
        };

        [request.insertedObjects enumerateObjectsUsingBlock:removeDocumentsBlock];
        [request.updatedObjects enumerateObjectsUsingBlock:removeDocumentsBlock];
        [request.deletedObjects enumerateObjectsUsingBlock:removeDocumentsBlock];

        for(map<string, IndexReader *>::iterator it = indexReaders->begin(); it != indexReaders->end(); it++) {
            it->second->close();
        }

        delete indexReaders;
        indexReaders = NULL;

        __block Document *document = _CLNEW Document();
        __block map<wstring, vector<Field *> > fields;

        void (^insertDocuments)(NSManagedObject *, BOOL *) = ^(NSManagedObject *object, BOOL *stop) {
            string entityString = string([object.entity.name cStringUsingEncoding:NSUTF8StringEncoding]);
            IndexWriter *indexWriter = NULL;
            map<string, IndexWriter *>::iterator it = indexWriters->find(entityString);
            if(it != indexWriters->end()) {
                indexWriter = it->second;
            }
            if(indexWriter == NULL) {
                indexWriter = [self indexWriterForEntity:object.entity];
            }
            if(indexWriter == NULL) {
                return;
            }
            void (^parseAttribute)(NSString *, NSAttributeDescription *, BOOL *) = ^(NSString *attributeName, NSAttributeDescription *attribute, BOOL * stop) {
                if(attribute.isLuceneIgnored) {
                    return;
                }
                id value = [object valueForKey:attributeName];
                if(value == nil) {
                    return;
                }
                wstring fieldName = wstring([attributeName toTCHAR]);
                const TCHAR *fieldValue = [self tcharFromValue:value type:attribute.attributeType];
                vector<Field *> fieldsForName = fields[fieldName];
                Field *field = NULL;
                int config = 0;
                if(attribute.isTransient) {
                    config = config|Field::STORE_NO;
                } else {
                    config = config|Field::STORE_YES;
                }
                if(attribute.isLuceneIndexed) {
                    if([attribute.userInfo[@"isTokenized"] boolValue]) {
                        config = config|Field::INDEX_TOKENIZED;
                    } else {
                        config = config|Field::INDEX_UNTOKENIZED;
                    }
                } else {
                    config = config|Field::INDEX_NO;
                }
                if(fieldsForName.size() == 0) {
                    field = _CLNEW Field(fieldName.c_str(), fieldValue, config, true);
                } else {
                    field = fieldsForName.back();
                    fieldsForName.pop_back();
                    TCHAR *valueToSet;
                    wcpcpy(valueToSet, fieldValue);
                    field->setValue(valueToSet, true);
                    free(valueToSet);
                }
                document->add(*field);
            };

            [object.entity.attributesByName enumerateKeysAndObjectsUsingBlock:parseAttribute];

            [object.entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString *relationshipName, NSRelationshipDescription *relationship, BOOL *stop) {
                id value = [object valueForKey:relationshipName];
                if(value == nil) {
                    return;
                }
                NSString *attributeForObjectID = relationship.destinationEntity.userInfo[OCLAttributeForObjectId];
                if(attributeForObjectID == nil) {
                    return;
                }
                wstring fieldName = [relationshipName toTCHAR];
                __block vector<Field *> fieldsForName = fields[fieldName];
                void (^parseRelatedObject)(NSManagedObject *, BOOL *) =  ^(NSManagedObject *object, BOOL *stop) {
                    const TCHAR *fieldValue = [[object valueForKey:attributeForObjectID] toTCHAR];
                    Field *field = NULL;
                    if(fieldsForName.size() == 0) {
                        field = _CLNEW Field(fieldName.c_str(), fieldValue, Field::STORE_YES|Field::INDEX_UNTOKENIZED, true);
                    } else {
                        field = fieldsForName.back();
                        TCHAR *valueToSet;
                        wcpcpy(valueToSet, fieldValue);
                        field->setValue(valueToSet, true);
                        free(valueToSet);
                    }
                    document->add(*field);
                };
                if([value isKindOfClass:[NSSet class]]) {
                    [(NSSet *)value enumerateObjectsUsingBlock:parseRelatedObject];
                } else {
                    BOOL stop = NO;
                    parseRelatedObject(value, &stop);
                }
            }];

            for(Field *field: *document->getFields()) {
                vector<Field *> fieldsForName = fields[wstring(field->name())];
                fieldsForName.push_back(field);
            }
            indexWriter->addDocument(document);
            document->clear();
            if(it == indexWriters->end()) {
                indexWriters->insert(pair<string, IndexWriter *>(entityString, indexWriter));
            }
        };

        [request.insertedObjects enumerateObjectsUsingBlock:insertDocuments];
        [request.updatedObjects enumerateObjectsUsingBlock:insertDocuments];

        for(map<wstring, vector<Field *> >::const_iterator it = fields.begin(); it != fields.end(); it++) {
            for(Field *field: it->second) {
                _CLVDELETE(field);
            }
        }

        for(map<string, IndexWriter *>::const_iterator it = indexWriters->begin(); it != indexWriters->end(); it++) {
            IndexWriter *indexWriter = it->second;
            indexWriter->setUseCompoundFile(true);
            indexWriter->optimize();
            indexWriter->flush();
            indexWriter->close();
            _CLVDELETE(indexWriter);
        }

        _CLVDELETE(document);

        delete indexWriters;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return @[];
}

- (NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    Term term = Term([objectID.entity.attributeNameForObjectId toTCHAR], [[self referenceObjectForObjectID:objectID] toTCHAR], true);
    TermQuery *query = _CLNEW TermQuery(&term);
    IndexReader *indexReader = [self indexReaderForEntity:objectID.entity];
    IndexSearcher indexSearcher = IndexSearcher(indexReader);
    Hits *hits = indexSearcher.search(query);
    if(hits->length() == 0) {
        return nil;
    }
    Document document = hits->doc(0);
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    for(Field *field: *document.getFields()) {
        NSString *fieldName = [NSString stringFromTCHAR:field->name()];
        NSAttributeDescription *attribute = objectID.entity.attributesByName[fieldName];
        NSRelationshipDescription *relationship = objectID.entity.relationshipsByName[fieldName];
        id fieldValue = nil;
        if(attribute != nil) {
            fieldValue = [self luceneValue:field->stringValue() type:attribute.attributeType];
        } else {
            fieldValue = [NSString stringFromTCHAR:field->stringValue()];
        }
        if(fieldValue == nil) {
            continue;
        }
        if(relationship != nil) {
            fieldValue = [self newObjectIDForEntity:relationship.destinationEntity referenceObject:fieldValue];
        }
        id currentValue = values[fieldName];
        if(currentValue == nil) {
            if(relationship != nil && relationship.isToMany) {
                values[fieldName] = [[NSMutableArray alloc] initWithObjects:fieldValue, nil];
            } else {
                values[fieldName] = fieldValue;
            }
        } else if([currentValue isKindOfClass:[NSMutableArray class]]) {
            [(NSMutableArray *)currentValue addObject:fieldValue];
        } else {
            values[fieldName] = [[NSMutableArray alloc] initWithObjects:fieldValue, nil];
        }
    }
//    [objectID.entity.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, NSAttributeDescription *attribute, BOOL *stop) {
//        if(values[attributeName] == nil) {
//            values[attributeName] = [NSNull null];
//        }
//    }];
    [objectID.entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString *relationshipName, NSRelationshipDescription *relationship, BOOL *stop) {
        if(values[relationshipName] != nil) {
            return;
        } else {
            if(relationship.isToMany) {
                values[relationshipName] = @[];
            } else {
                values[relationshipName] = [NSNull null];
            }
        }
    }];
    [self.valuesCache setObject:values forKey:objectID];
    indexReader->close();
    _CLVDELETE(indexReader);
    _CLVDELETE(query);
    NSIncrementalStoreNode *node = [[NSIncrementalStoreNode alloc] initWithObjectID:objectID withValues:values version:0];
    return node;
}

- (id)newValueForRelationship:(NSRelationshipDescription *)relationship forObjectWithID:(NSManagedObjectID *)objectID withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    return [[self.valuesCache objectForKey:objectID] objectForKey:relationship.name];
}

- (NSArray *)obtainPermanentIDsForObjects:(NSArray *)array error:(NSError *__autoreleasing *)error
{
    NSMutableArray *permanentIDs = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(NSManagedObject *object, NSUInteger index, BOOL *stop) {
        NSManagedObjectID *objectID = [self newObjectIDForEntity:object.entity referenceObject:[object oclId]];
        [permanentIDs addObject:objectID];
    }];
    return permanentIDs;
}

#pragma mark - Internal

- (IndexReader *)indexReaderForEntity:(NSEntityDescription *)entity
{
    NSString *path = [self pathForEntity:entity];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return NULL;
    }
    try {
        return IndexReader::open([path cStringUsingEncoding:NSASCIIStringEncoding]);
    } catch (CLuceneError *error) {
        return NULL;
    }
}

- (IndexWriter *)indexWriterForEntity:(NSEntityDescription *)entity
{
    NSString *path = [self pathForEntity:entity];
    bool create = false;
    if(![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        create = true;
    }
    try {
        Analyzer *analyzer = _analyzersByEntityName[entity.name];
        if(analyzer == NULL) {
            return NULL;
        }
        return _CLNEW IndexWriter([path cStringUsingEncoding:NSASCIIStringEncoding], analyzer, create);
    } catch (CLuceneError *error) {
        return NULL;
    }
}

- (NSString *)pathForEntity:(NSEntityDescription *)entity
{
    return [[self.URL URLByAppendingPathComponent:entity.name] path];
}

- (Query *)queryForRequest:(NSFetchRequest *)fetchRequest indexReader:(IndexReader *)indexReader
{
    if(fetchRequest.predicate == nil) {
        return _CLNEW MatchAllDocsQuery();
    } else {
        Analyzer *analyzer = _analyzersByEntityName[fetchRequest.entity.name];
        return [fetchRequest.entity queryForPredicate:fetchRequest.predicate indexReader:indexReader analyzer:analyzer];
    }
}

- (id)luceneValue:(const TCHAR *)value type:(NSAttributeType)attributeType
{
    switch (attributeType) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
        case NSBooleanAttributeType:
            return @(NumberTools::stringToLong(value));
            break;

        case NSDecimalAttributeType:
        case NSDoubleAttributeType:
        case NSFloatAttributeType:
            return @(NumericUtils::sortableLongToDouble(NumberTools::stringToLong(value)));
            break;

        case NSDateAttributeType:
            return [NSDate dateWithTimeIntervalSince1970:NumericUtils::sortableLongToDouble(NumberTools::stringToLong(value))];
            break;

        case NSManagedObjectIDResultType:
        case NSStringAttributeType:
            return [NSString stringFromTCHAR:value];
            break;

        default:
            break;
    }
    return nil;
}

- (const TCHAR *)tcharFromValue:(id)value type:(NSAttributeType)attributeType
{
    switch (attributeType) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
            return NumberTools::longToString([value longLongValue]);
            break;

        case NSDateAttributeType:
            value = @([value timeIntervalSince1970]);

        case NSDecimalAttributeType:
        case NSDoubleAttributeType:
        case NSFloatAttributeType:
            return NumberTools::longToString(NumericUtils::doubleToSortableLong([value doubleValue]));
            break;

        case NSManagedObjectIDResultType:
        case NSStringAttributeType:
            return [value toTCHAR];
            break;

        default:
            break;
    }
    return nil;
}

@end