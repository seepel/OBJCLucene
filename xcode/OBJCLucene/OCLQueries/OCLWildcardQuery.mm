//
//  OCLWildcardQuery.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLWildcardQuery.h"
#import "OCLQueryPrivate.h"
#import "OCLTermPrivate.h"
#import "WildcardQuery.h"

@interface OCLWildcardQuery () {
    OCLTerm *term_;
}

@end

@implementation OCLWildcardQuery

@synthesize term = term_;

- (id)initWithTerm:(OCLTerm *)term
{
    if((self = [super init])) {
        WildcardQuery *query = _CLNEW WildcardQuery([term cppTerm]);
        [self setCPPQuery:query];
        term_ = term;
    }
    return self;
}

@end

