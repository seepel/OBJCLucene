//
//  OCLIncrementalStoreDatePredicateTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/9/14.
//
//

#import "OCLIncrementalStorePredicateTests.h"

@interface OCLIncrementalStoreDatePredicateTests : OCLIncrementalStorePredicateTests

@end

@implementation OCLIncrementalStoreDatePredicateTests

- (void)setUp
{
    [super setUp];
    self.lowerTestValue = [NSDate dateWithTimeIntervalSince1970:1397076224];
    self.equalTestValue = [NSDate dateWithTimeIntervalSince1970:1397076225];
    self.upperTestValue = [NSDate dateWithTimeIntervalSince1970:1397076226];
}

- (void)testLessThenDatePredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K < %@", DateAttributeName, self.upperTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingLessThenDatePredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K < %@", DateAttributeName, self.lowerTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testFailingLessThenDateBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K < %@", DateAttributeName, self.equalTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Less Then Or Equal To Predicates


- (void)testLessThenOrEqualToDatePredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K <= %@", DateAttributeName, self.upperTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingLessThenOrEqualToDatePredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K <= %@", DateAttributeName, self.lowerTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testLessThenOrEqualToDateBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K <= %@", DateAttributeName, self.equalTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

#pragma mark - Greater Then Predicates

- (void)testGreaterThenDatePredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K > %@", DateAttributeName, self.lowerTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingGreaterThenDatePredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K > %@", DateAttributeName, self.upperTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testFailingGreaterThenDateBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K > %@", DateAttributeName, self.equalTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Greather Then Or Equal To Predicates

- (void)testGreaterThenOrEqualToDatePredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K >= %@", DateAttributeName, self.lowerTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingGreaterThenOrEqualToDatePredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K >= %@", DateAttributeName, self.upperTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testGreaterThenOrEqualToDateBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K >= %@", DateAttributeName, self.equalTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

#pragma mark - Equal To Predicates

- (void)testEqualToPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", DateAttributeName,  self.equalTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingEqualToObjectIDPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", DateAttributeName, self.lowerTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Not Equal To Predicates

- (void)testNotEqualToPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K != %@", DateAttributeName, self.upperTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingNotEqualToObjectIDPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K != %@", DateAttributeName, self.equalTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Between Predicates

- (void)testBetweenPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K between { %@, %@ }", DateAttributeName, self.lowerTestValue, self.upperTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testBetweenPredicateLowerBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K between { %@, %@ }", DateAttributeName, self.equalTestValue, self.upperTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testBetweenPredicateUpperBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K between { %@, %@ }", DateAttributeName, self.lowerTestValue, self.equalTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFaildingBetweenPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K between { %@, %@ }", DateAttributeName, self.upperTestValue, [NSDate dateWithTimeIntervalSince1970:[self.upperTestValue timeIntervalSince1970]+1]];
    NSUInteger resultCount = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(resultCount, 0, @"");
}

#pragma mark - Aggregate Predicates

- (void)testInPredicate
{
    NSMutableSet *expected = [NSMutableSet setWithObject:self.expectedObjectID];
    for(NSUInteger i = 0; i != 5; i++) {
        NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
        [object setValue:[NSString stringWithFormat:@"%d", i] forKey:ObjectIdAttributeName];
        [object setValue:[NSDate dateWithTimeIntervalSince1970:[self.lowerTestValue timeIntervalSince1970]+i] forKey:DateAttributeName];
        if(i == 1 || i == 2) {
            NSManagedObjectID *objectID = [self.store obtainPermanentIDsForObjects:@[ object ] error:nil][0];
            [expected addObject:objectID];
        }
    }
    [self.context save:nil];
    [self.context reset];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K in { %@, %@ }", DateAttributeName, self.equalTestValue, self.upperTestValue];
    request.resultType = NSManagedObjectIDResultType;
    NSSet *result = [NSSet setWithArray:[self.context executeFetchRequest:request error:nil]];
    XCTAssertEqualObjects(result, expected, @"");
}

@end
