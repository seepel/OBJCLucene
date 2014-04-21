//
//  OCLStoreModelTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/13/14.
//
//

#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>
#import "OCLStore.h"
#import "NSEntityDescription+OCL.h"

@interface OCLStoreModelTests : XCTestCase

@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, strong) NSPersistentStore *luceneStore;
@property (nonatomic, strong) NSPersistentStore *sqliteStore;

@end

@implementation OCLStoreModelTests

- (void)setUp
{
    [super setUp];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] init];

    NSEntityDescription *entity = [[NSEntityDescription alloc] init];
    entity.name = @"Entity";
    entity.userInfo = @{ OCLAttributeForObjectId: @"_id" };

    NSEntityDescription *searchEntity = [[NSEntityDescription alloc] init];
    searchEntity.name = @"SearchEntity";
    searchEntity.userInfo = @{ OCLAttributeForObjectId: @"_id" };

    NSAttributeDescription *idAttribute = [[NSAttributeDescription alloc] init];
    idAttribute.name = @"_id";
    idAttribute.indexed = YES;
    idAttribute.attributeType = NSStringAttributeType;

    NSAttributeDescription *searchIdAttribute = [[NSAttributeDescription alloc] init];
    searchIdAttribute.name = @"_id";
    searchIdAttribute.indexed = YES;
    searchIdAttribute.attributeType = NSStringAttributeType;

    NSAttributeDescription *searchAttribute = [[NSAttributeDescription alloc] init];
    searchAttribute.name = @"search";
    searchAttribute.indexed = YES;
    searchAttribute.attributeType = NSStringAttributeType;

    NSAttributeDescription *concreteAttribute = [[NSAttributeDescription alloc] init];
    concreteAttribute.name = @"concrete";
    concreteAttribute.attributeType = NSStringAttributeType;


    NSRelationshipDescription *searchRelationship = [[NSRelationshipDescription alloc] init];
    searchRelationship.name = @"searchEntity";
    searchRelationship.maxCount = 1;
    searchRelationship.transient = YES;

    NSRelationshipDescription *entityRelationship = [[NSRelationshipDescription alloc] init];
    entityRelationship.name = @"anEntity";
    entityRelationship.maxCount = 1;
    entityRelationship.transient = YES;

    searchRelationship.destinationEntity = searchEntity;
    entityRelationship.destinationEntity = entity;
    searchRelationship.inverseRelationship = entityRelationship;
    entityRelationship.inverseRelationship = searchRelationship;

    entity.properties = @[ idAttribute, concreteAttribute, searchRelationship ];
    searchEntity.properties = @[ searchIdAttribute, searchAttribute, entityRelationship ];

    model.entities = @[ entity, searchEntity ];

    [model setEntities:@[ entity ] forConfiguration:@"sqlite"];
    [model setEntities:@[ entity, searchEntity ] forConfiguration:@"lucene"];

    NSString *cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];

    for(NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDirectory error:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:[cacheDirectory stringByAppendingPathComponent:file] error:nil];
    }


    self.coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

    NSError *sqliteError = nil;
    NSURL *SQLiteURL =[NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"sqlite"]];
    sqliteError = nil;
    NSPersistentStore *sqliteStore = [self.coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:@"sqlite" URL:SQLiteURL options:nil error:&sqliteError];
    if(sqliteStore == nil) {
        NSLog(@"Error adding store: %@", sqliteError);
    }

    [OCLStore initialize];
    NSURL *URL = [NSURL fileURLWithPath:[cacheDirectory stringByAppendingPathComponent:@"lucene"]];
    [[NSFileManager defaultManager] removeItemAtPath:URL.path error:nil];
    NSError *error = nil;
    NSPersistentStore *luceneStore = (OCLStore *)[self.coordinator addPersistentStoreWithType:OCLStoreType configuration:@"lucene" URL:URL options:nil error:&error];
    if(luceneStore == nil) {
        NSLog(@"Error adding store: %@, %@", error, error.userInfo);
    }

    self.luceneStore = luceneStore;
    self.sqliteStore = sqliteStore;

    self.context = [[NSManagedObjectContext alloc] init];
    self.context.persistentStoreCoordinator = self.coordinator;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testDoubleSaveLuceneSearch
{
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKey:@"_id"];
    [object setValue:@"concrete" forKey:@"concrete"];
    NSManagedObject *searchObject = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"SearchEntity" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [searchObject setValue:@"id" forKeyPath:@"_id"];
    [searchObject setValue:@"search" forKeyPath:@"search"];
    [object setValue:searchObject forKeyPath:@"searchEntity"];
    @try {
        [self.context save:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }

    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] init];
    localContext.persistentStoreCoordinator = self.coordinator;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"lucene"];
    request.affectedStores = @[ self.luceneStore ];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", @"_id", @"id"];
    NSError *error = nil;
    NSArray *results = [localContext executeFetchRequest:request error:&error];
    XCTAssertEqual(results.count, 1, @"");
    NSManagedObject *result = results[0];
    XCTAssertEqualObjects([result valueForKey:result.entity.attributeNameForObjectId], [object valueForKey:result.entity.attributeNameForObjectId], @"");
}

- (void)testLuceneSearchOnly
{
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKey:@"_id"];
    [object setValue:@"concrete" forKey:@"concrete"];
    NSManagedObject *searchObject = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"SearchEntity" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [searchObject setValue:@"id" forKeyPath:@"_id"];
    [searchObject setValue:@"search" forKeyPath:@"search"];
    [object setValue:searchObject forKeyPath:@"searchEntity"];
    @try {
        [self.context save:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }

    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] init];
    localContext.persistentStoreCoordinator = self.coordinator;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"SearchEntity"];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"lucene"];
    NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
    NSPersistentStore *store = [self.coordinator persistentStoreForURL:url];
    request.affectedStores = @[ store ];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", @"search", @"search"];
    NSError *error = nil;
    NSArray *results = [localContext executeFetchRequest:request error:&error];
    XCTAssertEqual(results.count, 1, @"");
    XCTAssertEqualObjects([results[0] objectID], searchObject.objectID, @"");
}

- (void)testSQLiteSearchOnly
{
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKey:@"_id"];
    [object setValue:@"concrete" forKey:@"concrete"];
    NSManagedObject *searchObject = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"SearchEntity" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [searchObject setValue:@"id" forKeyPath:@"_id"];
    [searchObject setValue:@"search" forKeyPath:@"search"];
    [searchObject setValue:object forKeyPath:@"anEntity"];
    NSError *error = nil;
    if(![self.context save:&error]) {
        NSLog(@"Error: %@", error);
    }

    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] init];
    localContext.persistentStoreCoordinator = self.coordinator;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    NSURL *url = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"sqlite"] isDirectory:NO];
    NSPersistentStore *store = [self.coordinator persistentStoreForURL:url];
    request.affectedStores = @[ store ];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", @"concrete", @"concrete"];
    error = nil;
    NSArray *results = [localContext executeFetchRequest:request error:&error];
    XCTAssertEqual(results.count, 1, @"");
//    XCTAssertEqualObjects([results[0] objectID], object.objectID, @"");

}

@end
