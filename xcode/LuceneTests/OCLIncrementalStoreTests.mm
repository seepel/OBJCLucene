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

    NSAttributeDescription *integerAttribute = [[NSAttributeDescription alloc] init];
    integerAttribute.indexed = YES;
    integerAttribute.name = @"integer";
    integerAttribute.attributeType = NSInteger64AttributeType;

    NSAttributeDescription *floatAttribute = [[NSAttributeDescription alloc] init];
    floatAttribute.name = @"float";
    floatAttribute.attributeType = NSFloatAttributeType;
    floatAttribute.indexed = YES;

    NSAttributeDescription *stringAttribute = [[NSAttributeDescription alloc] init];
    stringAttribute.name = @"string";
    stringAttribute.attributeType = NSStringAttributeType;
    stringAttribute.indexed = YES;

    entity.properties = @[ integerAttribute, floatAttribute, stringAttribute ];
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
    [object setValue:@(1) forKeyPath:@"integer"];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    request.resultType = NSManagedObjectIDResultType;
    XCTAssertEqualObjects([self.context executeFetchRequest:request error:nil], @[ object.objectID ], @"");
}

- (void)testObjectRequest
{
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:@(1) forKeyPath:@"integer"];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    NSManagedObject *result = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(result, object, @"");
}

- (void)testDictionaryRequest
{
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:@(1) forKeyPath:@"integer"];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[ object.entity.propertiesByName[@"integer"] ];
    NSManagedObject *result = [self.context executeFetchRequest:request error:nil][0];
    NSDictionary *expected = @{ @"_id": @"id", @"integer": @(1) };
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testMultipleAdd
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context];
    for(int i=0; i!= 100; i++) {
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"id%02d", i];
        [object setValue:_id forKeyPath:@"_id"];
        [object setValue:@(1) forKeyPath:@"integer"];
        [expected addObject:[self.store newObjectIDForEntity:entity referenceObject:_id]];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    request.resultType = NSManagedObjectIDResultType;
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testSortDescriptor
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context];
    for(int i=0; i!= 100; i++) {
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"id%02d", i];
        [object setValue:_id forKeyPath:@"_id"];
        [object setValue:@(99-i) forKeyPath:@"integer"];
        [expected insertObject:object atIndex:0];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"integer" ascending:YES] ];
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testReverseSortDescriptor
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context];
    for(int i=0; i!= 100; i++) {
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"%02d", i];
        [object setValue:_id forKeyPath:@"_id"];
        [object setValue:@(99-i) forKeyPath:@"integer"];
        [expected addObject:object];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"integer" ascending:NO] ];
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testDoubleInsert
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context];
    for(int i=0; i!= 5; i++) {
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"%02d", i];
        [object setValue:_id forKeyPath:@"_id"];
        [object setValue:@(99-i) forKeyPath:@"integer"];
    }
    [self.context save:nil];
    for(int i=0; i!= 5; i++) {
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"%02d", i];
        [object setValue:_id forKeyPath:@"_id"];
        [object setValue:@(i) forKeyPath:@"integer"];
        [expected addObject:object];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"integer" ascending:YES] ];
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testDataRetrieval
{
    NSNumber *integerValue =  @(1);
    NSNumber *floatValue = @(1.1);
    NSString *stringValue = @"test";

    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:integerValue forKeyPath:@"integer"];
    [object setValue:floatValue forKeyPath:@"float"];
    [object setValue:stringValue forKeyPath:@"string"];
    [self.context save:nil];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = self.coordinator;
    OCLManagedObject *result = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Entity"] error:nil][0];
    XCTAssertEqualObjects([result valueForKey:@"integer"], integerValue, @"");
    XCTAssert(fabs(([[result valueForKey:@"float"] floatValue] - [floatValue floatValue])) < 0.001, @"actual: %@ expected: %@", [result valueForKey:@"float"], floatValue);
    XCTAssertEqualObjects([result valueForKey:@"string"], stringValue, @"");
}


@end
