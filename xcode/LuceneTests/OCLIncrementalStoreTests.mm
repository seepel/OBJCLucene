//
//  OCLIncrementalStoreTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 3/30/14.
//
//

#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>
#import "OCLIncrementalStore.h"
#import "OCLManagedObject.h"

@interface OCLIncrementalStoreTests : XCTestCase

@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) OCLIncrementalStore *store;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation OCLIncrementalStoreTests

- (void)setUp
{
    [super setUp];
    self.model = [[NSManagedObjectModel alloc] init];
    NSEntityDescription *entity = [[NSEntityDescription alloc] init];
    entity.managedObjectClassName = NSStringFromClass([OCLManagedObject class]);
    entity.name = @"Entity";
    NSAttributeDescription *attribute = [[NSAttributeDescription alloc] init];
    attribute.indexed = YES;
    attribute.name = @"attribute";
    attribute.attributeType = NSStringAttributeType;
    entity.properties = @[ attribute ];
    self.model.entities = @[ entity ];
    [OCLIncrementalStore initialize];
    self.coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    NSURL *URL = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"store"]];
    [[NSFileManager defaultManager] removeItemAtPath:URL.path error:nil];
    NSError *error = nil;
    self.store = (OCLIncrementalStore *)[self.coordinator addPersistentStoreWithType:OCLIncrementalStoreType configuration:nil URL:URL options:nil error:&error];
    if(self.store == nil) {
        NSLog(@"Error adding store: %@, %@", error, error.userInfo);
    }
    self.context = [[NSManagedObjectContext alloc] init];
    self.context.persistentStoreCoordinator = self.coordinator;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInitialization
{
    XCTAssertEqual(1, self.coordinator.persistentStores.count, @"");
}

- (void)testSingleCountRequest
{
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:@"test" forKeyPath:@"attribute"];
    BOOL success = [self.context save:nil];
    XCTAssertTrue(success, @"");
    XCTAssertTrue(!object.objectID.isTemporaryID, @"");
    XCTAssertEqualObjects(object.objectID, [self.store newObjectIDForEntity:object.entity referenceObject:@"id"], @"");
    XCTAssertEqual([self.context countForFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Entity"]  error:nil], 1, @"");
}

- (void)testObjectIdRequest
{
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:@"test" forKeyPath:@"attribute"];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    request.resultType = NSManagedObjectIDResultType;
    XCTAssertEqualObjects([self.context executeFetchRequest:request error:nil], @[ object.objectID ], @"");
}

- (void)testObjectRequest
{
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:@"test" forKeyPath:@"attribute"];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    NSManagedObject *result = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(result, object, @"");
}

- (void)testDictionaryRequest
{
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:@"test" forKeyPath:@"attribute"];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[ object.entity.propertiesByName[@"attribute"] ];
    NSManagedObject *result = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(result, @{ @"attribute": @"test" }, @"");
}

@end
