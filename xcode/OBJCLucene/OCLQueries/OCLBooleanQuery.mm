//
//  OCLBooleanQuery.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLBooleanQuery.h"
#import "OCLQueryPrivate.h"
#import "BooleanQuery.h"
#import "OCLBooleanClausePrivate.h"

@interface OCLBooleanQuery () {
    NSMutableArray *booleanClauses_;
}

@end

@implementation OCLBooleanQuery

@synthesize booleanClauses = booleanClauses_;

- (id)initWithClauses:(NSArray *)booleanClauses
{
    if((self = [super init])) {
        BooleanQuery *query = _CLNEW BooleanQuery();
        [self setCPPQuery:query];
        booleanClauses_ = [NSMutableArray arrayWithCapacity:booleanClauses.count];
        for(OCLBooleanClause *clause in booleanClauses) {
            [self addClause:clause];
        }
    }
    return self;
}

- (void)addClause:(OCLBooleanClause *)booleanClause
{
    [booleanClauses_ addObject:booleanClause];
    BooleanQuery *query = (BooleanQuery *)[self cppQuery];
    query->add([booleanClause cppBooleanClause]);
}

- (void)addQuery:(OCLQuery *)query occur:(OCLBooleanClauseOccur)occur
{
    OCLBooleanClause *clause = [[OCLBooleanClause alloc] initWithQuery:query occur:occur];
    [self addClause:clause];
}

@end