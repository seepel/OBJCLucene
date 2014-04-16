//
//  OCLIncrementalStoreStringPredicateTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/9/14.
//
//

#import "OCLIncrementalStorePredicateTests.h"

@interface OCLIncrementalStoreStringPredicateTests : OCLIncrementalStorePredicateTests

@end

@implementation OCLIncrementalStoreStringPredicateTests

- (void)setUp
{
    [super setUp];
    self.lowerTestValue = @"Tess";
    self.equalTestValue = @"Test";
    self.upperTestValue = @"Tesu";
}

#pragma mark - Less Then Predicates

- (void)testLessThenStringPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K < %@", StringAttributeName, self.upperTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingLessThenStringPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K < %@", StringAttributeName, self.lowerTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testFailingLessThenStringBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K < %@", StringAttributeName, self.equalTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Less Then Or Equal To Predicates


- (void)testLessThenOrEqualToStringPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K <= %@", StringAttributeName, self.upperTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingLessThenOrEqualToStringPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K <= %@", StringAttributeName, self.lowerTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testLessThenOrEqualToStringBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K <= %@", StringAttributeName, self.equalTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

#pragma mark - Greater Then Predicates

- (void)testGreaterThenStringPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K > %@", StringAttributeName, self.lowerTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingGreaterThenStringPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K > %@", StringAttributeName, self.upperTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testFailingGreaterThenStringBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K > %@", StringAttributeName, self.equalTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Greather Then Or Equal To Predicates

- (void)testGreaterThenOrEqualToStringPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K >= %@", StringAttributeName, self.lowerTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingGreaterThenOrEqualToStringPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K >= %@", StringAttributeName, self.upperTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

- (void)testGreaterThenOrEqualToStringBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K >= %@", StringAttributeName, self.equalTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

#pragma mark - Equal To Predicates

- (void)testEqualToPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", StringAttributeName,  self.equalTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingEqualToObjectIDPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", StringAttributeName, self.lowerTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Not Equal To Predicates

- (void)testNotEqualToPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K != %@", StringAttributeName, self.upperTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFailingNotEqualToObjectIDPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K != %@", StringAttributeName, self.equalTestValue];
    NSUInteger numberOfResults = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(numberOfResults, 0, @"");
}

#pragma mark - Between Predicates

- (void)testBetweenPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K between { %@, %@ }", StringAttributeName, self.lowerTestValue, self.upperTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testBetweenPredicateLowerBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K between { %@, %@ }", StringAttributeName, self.equalTestValue, self.upperTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testBetweenPredicateUpperBoundaryPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K between { %@, %@ }", StringAttributeName, self.lowerTestValue, self.equalTestValue];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

- (void)testFaildingBetweenPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K between { %@, %@ }", StringAttributeName, self.upperTestValue, @"Z"];
    NSUInteger resultCount = [[self.context executeFetchRequest:request error:nil] count];
    XCTAssertEqual(resultCount, 0, @"");
}

#pragma mark - Aggregate Predicates

- (void)testInPredicate
{
    NSMutableSet *expected = [NSMutableSet setWithObject:self.expectedObjectID];
    NSArray *values = @[ self.lowerTestValue, self.equalTestValue, self.upperTestValue, @"Tesy", @"Tesz" ];
    for(NSUInteger i = 0; i != 5; i++) {
        NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
        [object setValue:[NSString stringWithFormat:@"%d", i] forKey:ObjectIdAttributeName];
        [object setValue:values[i] forKey:StringAttributeName];
        if(i == 1 || i == 2) {
            NSManagedObjectID *objectID = [self.store obtainPermanentIDsForObjects:@[ object ] error:nil][0];
            [expected addObject:objectID];
        }
    }
    [self.context save:nil];
    [self.context reset];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K in { %@, %@ }", StringAttributeName, self.equalTestValue, self.upperTestValue];
    request.resultType = NSManagedObjectIDResultType;
    NSSet *result = [NSSet setWithArray:[self.context executeFetchRequest:request error:nil]];
    XCTAssertEqualObjects(result, expected, @"");
}

@end
