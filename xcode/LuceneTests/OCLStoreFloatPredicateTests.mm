//
//  OCLStoreFloatPredicateTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/9/14.
//
//

#import "OCLStorePredicateTests.h"

@interface OCLStoreFloatPredicateTests : OCLStorePredicateTests

@end

@implementation OCLStoreFloatPredicateTests

#pragma mark - Less Then Predicates

- (void)testLessThenFloatPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K < %@", FloatAttributeName, @(2.f)];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingLessThenFloatPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K < %@", FloatAttributeName, @(0.f)];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testFailingLessThenFloatBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K < %@", FloatAttributeName, @(1.1f)];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Less Then Or Equal To Predicates


- (void)testLessThenOrEqualToFloatPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K <= %@", FloatAttributeName, @(2.f)];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingLessThenOrEqualToFloatPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K <= %@", FloatAttributeName, @(0.f)];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testLessThenOrEqualToFloatBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K <= %@", FloatAttributeName, @(1.1f)];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

#pragma mark - Greater Then Predicates

- (void)testGreaterThenFloatPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K > %@", FloatAttributeName, @(0.f)];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingGreaterThenFloatPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K > %@", FloatAttributeName, @(2.f)];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testFailingGreaterThenFloatBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K > %@", FloatAttributeName, @(1.1f)];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Greather Then Or Equal To Predicates

- (void)testGreaterThenOrEqualToFloatPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K >= %@", FloatAttributeName, @(0.f)];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingGreaterThenOrEqualToFloatPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K >= %@", FloatAttributeName, @(2.f)];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testGreaterThenOrEqualToFloatBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K >= %@", FloatAttributeName, @(1.1f)];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

#pragma mark - Equal To Predicates

- (void)testEqualToPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", FloatAttributeName,  @(1.1f)];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingEqualToObjectIDPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", FloatAttributeName, @(1.11f)];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Not Equal To Predicates

- (void)testNotEqualToPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K != %@", FloatAttributeName, @(2.f)];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingNotEqualToObjectIDPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K != %@", FloatAttributeName, @(1.1f)];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Between Predicates

- (void)testBetweenPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K between { %@, %@ }", FloatAttributeName, @(0.f), @(2.f)];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testBetweenPredicateLowerBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K between { %@, %@ }", FloatAttributeName, @(1.1f), @(2.f)];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testBetweenPredicateUpperBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K between { %@, %@ }", FloatAttributeName, @(0.f), @(1.11f)];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFaildingBetweenPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K between { %@, %@ }", FloatAttributeName, @(2.f), @(500.f)];
    NSUInteger resultCount = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(resultCount, 0, @"");
}

#pragma mark - Aggregate Predicates

- (void)testInPredicate
{
    NSMutableSet *expected = [NSMutableSet setWithObject:self.expectedObjectID];
    for(NSUInteger i = 0; i != 5; i++) {
        NSUInteger value = i;
        NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
        [object setValue:[NSString stringWithFormat:@"%d", i] forKey:ObjectIdAttributeName];
        [object setValue:@(value) forKey:FloatAttributeName];
        [object setValue:@(value+0.1) forKey:FloatAttributeName];
        if(i == 1 || i == 2) {
            NSManagedObjectID *objectID = [self.store obtainPermanentIDsForObjects:@[ object ] error:nil][0];
            [expected addObject:objectID];
        }
    }
    [self.context save:nil];
    [self.context reset];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K in { %@, %@ }", FloatAttributeName, @(1.1f), @(2.1f)];
    request.resultType = NSManagedObjectIDResultType;
    NSSet *result = [NSSet setWithArray:[self.context executeFetchRequest:request error:nil]];
    XCTAssertEqualObjects(result, expected, @"");
}

@end
