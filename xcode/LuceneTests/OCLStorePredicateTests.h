//
//  OCLStorePredicateTests.h
//  OBJCLucene
//
//  Created by Sean Lynch on 4/9/14.
//
//

#import "OCLStoreTests.h"

@interface OCLStorePredicateTests : OCLStoreTests

@property (nonatomic, strong) NSManagedObjectID *expectedObjectID;
@property (nonatomic, strong) id lowerTestValue;
@property (nonatomic, strong) id equalTestValue;
@property (nonatomic, strong) id upperTestValue;

@end
