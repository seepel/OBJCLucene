//
//  OCLStoreQueryPredicateTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/16/14.
//
//

#import "OCLStorePredicateTests.h"
#import "OCLPredicate.h"

@interface OCLStoreQueryPredicateTests : OCLStorePredicateTests

@end

@implementation OCLStoreQueryPredicateTests

- (void)testOCLPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    int value = 1;
    request.predicate = [OCLPredicate predicateWithFormat:@"%K:%d", IntegerAttributeName, value];
    NSManagedObject *object = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(object.objectID, self.expectedObjectID, @"");
}

@end
