//
//  OCLIncrementalStoreIntegerPredicateTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/9/14.
//
//

#import "OCLIncrementalStorePredicateTests.h"

@interface OCLIncrementalStoreIntegerPredicateTests : OCLIncrementalStorePredicateTests

@end

@implementation OCLIncrementalStoreIntegerPredicateTests

#pragma mark - Less Then Predicates

- (void)testLessThenIntegerPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K < 2", IntegerAttributeName];
    OCLManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingLessThenIntegerPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K < 0", IntegerAttributeName];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testFailingLessThenIntegerBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K < 1", IntegerAttributeName];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Less Then Or Equal To Predicates


- (void)testLessThenOrEqualToIntegerPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K <= 2", IntegerAttributeName];
    OCLManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingLessThenOrEqualToIntegerPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K <= 0", IntegerAttributeName];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testLessThenOrEqualToIntegerBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K <= 1", IntegerAttributeName];
    OCLManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

#pragma mark - Greater Then Predicates

- (void)testGreaterThenIntegerPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K > 0", IntegerAttributeName];
    OCLManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingGreaterThenIntegerPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K > 2", IntegerAttributeName];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testFailingGreaterThenIntegerBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K > 1", IntegerAttributeName];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Greather Then Or Equal To Predicates

- (void)testGreaterThenOrEqualToIntegerPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K >= 0", IntegerAttributeName];
    OCLManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingGreaterThenOrEqualToIntegerPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K >= 2", IntegerAttributeName];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testGreaterThenOrEqualToIntegerBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K >= 1", IntegerAttributeName];
    OCLManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

#pragma mark - Equal To Predicates

- (void)testEqualToPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"integer = 1"];
    OCLManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingEqualToObjectIDPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"integer = 2"];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Not Equal To Predicates

- (void)testNotEqualToPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"integer != 2"];
    OCLManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingNotEqualToObjectIDPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"integer != 1"];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Between Predicates

- (void)testBetweenPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"integer between { 0, 2 }"];
    OCLManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testBetweenPredicateLowerBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"integer between { 1, 2 }"];
    OCLManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testBetweenPredicateUpperBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"integer between { 0, 1 }"];
    OCLManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFaildingBetweenPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"integer between { 2, 500 }"];
    NSUInteger resultCount = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(resultCount, 0, @"");
}

#pragma mark - Aggregate Predicates

- (void)testInPredicate
{
    NSMutableSet *expected = [NSMutableSet setWithObject:self.expectedObjectID];
    for(NSUInteger i = 0; i != 5; i++) {
        NSUInteger value = i;
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
        object._id = [NSString stringWithFormat:@"%d", i];
        [object setValue:@(value) forKey:IntegerAttributeName];
        [object setValue:@(value+0.1) forKey:IntegerAttributeName];
        if(i == 1 || i == 2) {
            NSManagedObjectID *objectID = [self.store obtainPermanentIDsForObjects:@[ object ] error:nil][0];
            [expected addObject:objectID];
        }
    }
    [self.context save:nil];
    [self.context reset];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"integer in { 1, 2 }"];
    request.resultType = NSManagedObjectIDResultType;
    NSSet *result = [NSSet setWithArray:[self.context executeFetchRequest:request error:nil]];
    XCTAssertEqualObjects(result, expected, @"");
}

@end
