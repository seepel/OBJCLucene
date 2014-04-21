//
//  OCLStoreBaseTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/9/14.
//
//

#import "OCLStoreTests.h"

@interface OCLStoreBaseTests : OCLStoreTests

@end

@implementation OCLStoreBaseTests

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
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:ObjectIdAttributeName];
    BOOL success = [self.context save:nil];
    XCTAssertTrue(success, @"");
    XCTAssertTrue(!object.objectID.isTemporaryID, @"");
    XCTAssertEqualObjects(object.objectID, [self.store newObjectIDForEntity:object.entity referenceObject:@"id"], @"");
    XCTAssertEqual([self.context countForFetchRequest:[[NSFetchRequest alloc] initWithEntityName:RootEntityName]  error:nil], 1, @"");
}

- (void)testObjectIdRequest
{
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:ObjectIdAttributeName];
    [object setValue:@(1) forKeyPath:IntegerAttributeName];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.resultType = NSManagedObjectIDResultType;
    XCTAssertEqualObjects([self.context executeFetchRequest:request error:nil], @[ object.objectID ], @"");
}

- (void)testObjectRequest
{
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:ObjectIdAttributeName];
    [object setValue:@(1) forKeyPath:IntegerAttributeName];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    NSManagedObject *result = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(result, object, @"");
}

- (void)testDictionaryRequest
{
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:ObjectIdAttributeName];
    [object setValue:@(1) forKeyPath:IntegerAttributeName];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[ object.entity.propertiesByName[IntegerAttributeName] ];
    NSManagedObject *result = [self.context executeFetchRequest:request error:nil][0];
    NSDictionary *expected = @{ ObjectIdAttributeName: @"id", IntegerAttributeName: @(1) };
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testMultipleAdd
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context];
    for(int i=0; i!= 100; i++) {
        NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"id%02d", i];
        [object setValue:_id forKeyPath:ObjectIdAttributeName];
        [object setValue:@(1) forKeyPath:IntegerAttributeName];
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
        NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"id%02d", i];
        [object setValue:_id forKeyPath:ObjectIdAttributeName];
        [object setValue:@(99-i) forKeyPath:IntegerAttributeName];
        [expected insertObject:object atIndex:0];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:IntegerAttributeName ascending:YES] ];
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects([NSSet setWithArray:result], [NSSet setWithArray:expected], @"");
}

- (void)testReverseSortDescriptor
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context];
    for(int i=0; i!= 100; i++) {
        NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"%02d", i];
        [object setValue:_id forKeyPath:ObjectIdAttributeName];
        [object setValue:@(99-i) forKeyPath:IntegerAttributeName];
        [expected addObject:object];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:IntegerAttributeName ascending:NO] ];
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects([NSSet setWithArray:result], [NSSet setWithArray:expected], @"");
}

- (void)testDoubleInsert
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context];
    for(int i=0; i!= 5; i++) {
        NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"%02d", i];
        [object setValue:_id forKeyPath:ObjectIdAttributeName];
        [object setValue:@(99-i) forKeyPath:IntegerAttributeName];
    }
    [self.context save:nil];
    for(int i=0; i!= 5; i++) {
        NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"%02d", i];
        [object setValue:_id forKeyPath:ObjectIdAttributeName];
        [object setValue:@(i) forKeyPath:IntegerAttributeName];
        [expected addObject:object];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:IntegerAttributeName ascending:YES] ];
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testDataRetrieval
{
    NSNumber *integerValue =  @(1);
    NSNumber *floatValue = @(1.1f);
    NSString *stringValue = @"test";

    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:ObjectIdAttributeName];
    [object setValue:integerValue forKeyPath:IntegerAttributeName];
    [object setValue:floatValue forKeyPath:FloatAttributeName];
    [object setValue:stringValue forKeyPath:StringAttributeName];
    [self.context save:nil];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = self.coordinator;
    NSManagedObject *result = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:RootEntityName] error:nil][0];
    XCTAssertEqualObjects([result valueForKey:IntegerAttributeName], integerValue, @"");
    XCTAssertEqual([[result valueForKey:FloatAttributeName] doubleValue], [floatValue doubleValue], @"actual: %@ expected: %@", [result valueForKey:FloatAttributeName], floatValue);
    XCTAssertEqualObjects([result valueForKey:StringAttributeName], stringValue, @"");
}

@end
