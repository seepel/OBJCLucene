//
//  OCLIncrementalStoreBaseTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/9/14.
//
//

#import "OCLIncrementalStoreTests.h"

@interface OCLIncrementalStoreBaseTests : OCLIncrementalStoreTests

@end

@implementation OCLIncrementalStoreBaseTests

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
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    BOOL success = [self.context save:nil];
    XCTAssertTrue(success, @"");
    XCTAssertTrue(!object.objectID.isTemporaryID, @"");
    XCTAssertEqualObjects(object.objectID, [self.store newObjectIDForEntity:object.entity referenceObject:@"id"], @"");
    XCTAssertEqual([self.context countForFetchRequest:[[NSFetchRequest alloc] initWithEntityName:RootEntityName]  error:nil], 1, @"");
}

- (void)testObjectIdRequest
{
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:@(1) forKeyPath:@"integer"];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.resultType = NSManagedObjectIDResultType;
    XCTAssertEqualObjects([self.context executeFetchRequest:request error:nil], @[ object.objectID ], @"");
}

- (void)testObjectRequest
{
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:@(1) forKeyPath:@"integer"];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    NSManagedObject *result = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(result, object, @"");
}

- (void)testDictionaryRequest
{
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:@(1) forKeyPath:@"integer"];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[ object.entity.propertiesByName[@"integer"] ];
    NSManagedObject *result = [self.context executeFetchRequest:request error:nil][0];
    NSDictionary *expected = @{ @"_id": @"id", @"integer": @(1) };
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testMultipleAdd
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context];
    for(int i=0; i!= 100; i++) {
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"id%02d", i];
        [object setValue:_id forKeyPath:@"_id"];
        [object setValue:@(1) forKeyPath:@"integer"];
        [expected addObject:[self.store newObjectIDForEntity:entity referenceObject:_id]];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.resultType = NSManagedObjectIDResultType;
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects([NSSet setWithArray:result], [NSSet setWithArray:expected], @"");
}

- (void)testSortDescriptor
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context];
    for(int i=0; i!= 100; i++) {
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"id%02d", i];
        [object setValue:_id forKeyPath:@"_id"];
        [object setValue:@(99-i) forKeyPath:@"integer"];
        [expected insertObject:object atIndex:0];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"integer" ascending:YES] ];
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects([NSSet setWithArray:result], [NSSet setWithArray:expected], @"");
}

- (void)testReverseSortDescriptor
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context];
    for(int i=0; i!= 100; i++) {
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"%02d", i];
        [object setValue:_id forKeyPath:@"_id"];
        [object setValue:@(99-i) forKeyPath:@"integer"];
        [expected addObject:object];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"integer" ascending:NO] ];
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects([NSSet setWithArray:result], [NSSet setWithArray:expected], @"");
}

- (void)testDoubleInsert
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context];
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
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"integer" ascending:YES] ];
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testDataRetrieval
{
    NSNumber *integerValue =  @(1);
    NSNumber *floatValue = @(1.1f);
    NSString *stringValue = @"test";

    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:integerValue forKeyPath:@"integer"];
    [object setValue:floatValue forKeyPath:@"float"];
    [object setValue:stringValue forKeyPath:@"string"];
    [self.context save:nil];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = self.coordinator;
    OCLManagedObject *result = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:RootEntityName] error:nil][0];
    XCTAssertEqualObjects([result valueForKey:@"integer"], integerValue, @"");
    XCTAssertEqual([[result valueForKey:@"float"] doubleValue], [floatValue doubleValue], @"actual: %@ expected: %@", [result valueForKey:@"float"], floatValue);
    XCTAssertEqualObjects([result valueForKey:@"string"], stringValue, @"");
}

@end
