//
//  OCLIncrementalStore.m
//  OBJCLucene
//
//  Created by Sean Lynch on 3/30/14.
//
//

#import "OCLIncrementalStore.h"

#import "OBJCLucene.h"
#include "CLucene.h"

#import "OCLManagedObject.h"
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

using namespace ocl;
using namespace lucene::index;
using namespace lucene::search;
using namespace lucene::analysis::standard;
using namespace lucene::document;
using namespace std;

static NSString *OCLIncrementalStoreMetadataFileName = @"metadata";
NSString * const OCLIncrementalStoreType = @"OCLIncrementalStore";

@interface OCLIncrementalStore () {
    StandardAnalyzer *_analyzer;
}

@property (nonatomic, strong) NSOperationQueue *writeOperationQueue;

@end

@implementation OCLIncrementalStore

#pragma mark - Initialization

+ (void)initialize {
    [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:OCLIncrementalStoreType];
}

+ (NSString *)type {
    return OCLIncrementalStoreType;
}

- (BOOL)loadMetadata:(NSError *__autoreleasing *)error
{
    NSURL *url = [self.URL URLByAppendingPathComponent:OCLIncrementalStoreMetadataFileName];
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.URL.path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:self.URL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfURL:url]];
    if(dictionary == nil) {
        dictionary = @{ NSStoreTypeKey: OCLIncrementalStoreType, NSStoreUUIDKey: [[NSProcessInfo processInfo] globallyUniqueString] };
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
    const TCHAR *stopWords[1] = { NULL };
    _analyzer = _CLNEW StandardAnalyzer(stopWords);
    return YES;
}

- (void)dealloc
{
    if(_analyzer != NULL) {
        _CLVDELETE(_analyzer);
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
    MatchAllDocsQuery *query = _CLNEW MatchAllDocsQuery();
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
        wstring idString = [@"_id" toTCHAR];
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
                id _id1 = obj1[@"_id"];
                id _id2 = obj2[@"_id"];
                return [_id1 compare:_id2];
            }];
            [documentResults insertObject:documentResult atIndex:index];
            switch (request.resultType) {
                case NSManagedObjectIDResultType:
                    [results insertObject:[self newObjectIDForEntity:request.entity referenceObject:documentResult[@"_id"]] atIndex:index];
                    break;
                    
                case NSManagedObjectResultType:
                    [results insertObject:[context objectWithID:[self newObjectIDForEntity:request.entity referenceObject:documentResult[@"_id"]]] atIndex:index];
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

- (NSArray *)executeSaveRequest:(NSSaveChangesRequest *)request withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.writeOperationQueue addOperationWithBlock:^(void) {
        map<string, IndexReader *> *indexReaders = new map<string, IndexReader *>();
        map<string, IndexWriter *> *indexWriters = new map<string, IndexWriter *>();

//        NSMutableDictionary *indexReaders = [NSMutableDictionary dictionary];
        void (^removeDocumentsBlock)(OCLManagedObject *, BOOL *stop) = ^(OCLManagedObject *object, BOOL *stop) {
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
            indexReader->deleteDocuments(new Term([@"_id" toTCHAR], [object._id toTCHAR], true));
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

        NSAttributeDescription *idAttribute = [[NSAttributeDescription alloc] init];
        idAttribute.name = @"_id";
        idAttribute.attributeType = NSStringAttributeType;
        idAttribute.indexed = YES;

        void (^insertDocuments)(OCLManagedObject *, BOOL *) = ^(OCLManagedObject *object, BOOL *stop) {
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
                if(attribute.isIndexed) {
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
                    field->setValue(valueToSet);
                }
                document->add(*field);
            };
            BOOL idStop = NO;
            parseAttribute(@"_id", idAttribute, &idStop);
            [object.entity.attributesByName enumerateKeysAndObjectsUsingBlock:parseAttribute];
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
    Term term = Term([@"_id" toTCHAR], [[self referenceObjectForObjectID:objectID] toTCHAR], true);
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
        id currentValue = values[fieldName];
        if(currentValue == nil) {
            if(relationship != nil) {
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
    [objectID.entity.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, NSAttributeDescription *attribute, BOOL *stop) {
        if(values[attributeName] == nil) {
            values[attributeName] = [NSNull null];
        }
    }];
    [objectID.entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString *relationshipName, NSRelationshipDescription *relationship, BOOL *stop) {
        if(relationship.isToMany) {
            values[relationshipName] = @[];
        } else {
            values[relationshipName] = [NSNull null];
        }
    }];
    indexReader->close();
    _CLVDELETE(indexReader);
    _CLVDELETE(query);
    NSIncrementalStoreNode *node = [[NSIncrementalStoreNode alloc] initWithObjectID:objectID withValues:values version:0];
    return node;
}

- (id)newValueForRelationship:(NSRelationshipDescription *)relationship forObjectWithID:(NSManagedObjectID *)objectID withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    return nil;
}

- (NSArray *)obtainPermanentIDsForObjects:(NSArray *)array error:(NSError *__autoreleasing *)error
{
    NSMutableArray *permanentIDs = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(NSManagedObject *object, NSUInteger index, BOOL *stop) {
        [permanentIDs addObject:[self newObjectIDForEntity:object.entity referenceObject:[object valueForKey:@"_id"]]];
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
        return _CLNEW IndexWriter([path cStringUsingEncoding:NSASCIIStringEncoding], _analyzer, create);
    } catch (CLuceneError *error) {
        return NULL;
    }
}

- (NSString *)pathForEntity:(NSEntityDescription *)entity
{
    return [[self.URL URLByAppendingPathComponent:entity.name] path];
}

- (OCLQuery *)queryForRequest:(NSFetchRequest *)fetchRequest
{
    if(fetchRequest.predicate == nil) {
        return [OCLQuery allDocsQuery];
    } else {
        return nil;
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
            return NumberTools::longToString([value longValue]);
            break;

        case NSDecimalAttributeType:
        case NSDoubleAttributeType:
        case NSFloatAttributeType:
            return NumberTools::longToString(NumericUtils::doubleToSortableLong([value doubleValue]));
            break;

        case NSStringAttributeType:
            return [value toTCHAR];
            break;

        default:
            break;
    }
    return nil;
}

@end
