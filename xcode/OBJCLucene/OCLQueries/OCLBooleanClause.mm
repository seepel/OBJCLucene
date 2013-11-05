//
//  OCLBooleanClause.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLBooleanClause.h"
#import "OCLQueryPrivate.h"
#import "BooleanClause.h"

@implementation OCLBooleanClause

@synthesize query = query_;
@synthesize occur = occur_;

- (id)initWithQuery:(OCLQuery *)query occur:(OCLBooleanClauseOccur)occur
{
    if((self = [super init])) {
        query_ = query;
        occur_ = occur;
    }
    return self;
}

- (void)setQuery:(OCLQuery *)query
{
    query_ = query;
}

- (void)setOccur:(OCLBooleanClauseOccur)occur
{
    occur_ = occur;
}

@end
