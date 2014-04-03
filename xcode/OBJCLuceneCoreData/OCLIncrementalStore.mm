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
    _analyzer = new StandardAnalyzer(stopWords);
    return YES;
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
    switch (request.resultType) {
        case NSCountResultType: {
            selectorBlock = ^(const TCHAR *fieldName) {
                return FieldSelector::SIZE_AND_BREAK;
            };
            hitCollectorBlock = ^(Document document, float_t score) {
                ++count;
            };
            parseResults = ^(void) {
                return @[ @(count) ];
            };
            break;
        }

        case NSManagedObjectResultType:
        case NSManagedObjectIDResultType: {
            NSMutableArray *result = [NSMutableArray array];
            const TCHAR *idFieldName = [@"_id" toTCHAR];
            selectorBlock = ^(const TCHAR *fieldName) {
                if(wcscmp(idFieldName, fieldName) == 0) {
                    return FieldSelector::LOAD_AND_BREAK;
                }
                return FieldSelector::NO_LOAD;
            };
            hitCollectorBlock = ^(Document document, float_t score) {
                const TCHAR *idValue = document.getField(idFieldName)->stringValue();
                if(idValue == NULL) {
                    return;
                }
                NSString *_id = [NSString stringFromTCHAR:idValue];
                NSManagedObjectID *objectID = [self newObjectIDForEntity:request.entity referenceObject:_id];
                if(request.resultType == NSManagedObjectIDResultType) {
                    [result addObject:objectID];
                } else {
                    [result addObject:[context objectWithID:objectID]];
                }
            };
            parseResults = ^(void) {
                return result;
            };
            break;
        }

        case NSDictionaryResultType: {
            __block set<wstring> fields;
            [request.propertiesToFetch enumerateObjectsUsingBlock:^(id property, NSUInteger index, BOOL *stop) {
                if([property isKindOfClass:[NSAttributeDescription class]]) {
                    NSAttributeDescription *attribute = property;
                    fields.insert([attribute.name toTCHAR]);
                }
            }];
            selectorBlock = ^(const TCHAR *fieldName) {
                if(fields.find(fieldName) != fields.end()) {
                    return FieldSelector::LOAD;
                }
                return FieldSelector::NO_LOAD;
            };
            NSMutableArray *result = [NSMutableArray array];
            hitCollectorBlock = ^(Document document, float_t score) {
                NSMutableDictionary *documentResult = [NSMutableDictionary dictionary];
                for(Field *field: *document.getFields()) {
                    NSString *fieldName = [NSString stringFromTCHAR:field->name()];
                    id fieldResult = documentResult[fieldName];
                    id fieldValue = [self luceneValue:[NSString stringFromTCHAR:field->stringValue()]];
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
                    [result addObject:documentResult];
                }
            };
            parseResults = ^(void) {
                return result;
            };
            break;
        }
    }
    BlockHitCollector hitCollector = BlockHitCollector(selectorBlock, hitCollectorBlock, indexReader);
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

        __block Document *document = new Document();
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
                const TCHAR *fieldValue = [[self luceneValue:value] toTCHAR];
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
#pragma message("FIXME Memory leak")
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
    return nil;
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
        return new IndexWriter([path cStringUsingEncoding:NSASCIIStringEncoding], _analyzer, create);
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

- (NSString *)luceneValue:(id)value
{
    return value;
}

@end
