//
//  OCLPrefixQuery.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLPrefixQuery.h"
#import "OCLQueryPrivate.h"
#import "OCLTermPrivate.h"
#import "PrefixQuery.h"

@interface OCLPrefixQuery () {
    OCLTerm *term_;
}

@end

@implementation OCLPrefixQuery

@synthesize term = term_;

- (id)initWithTerm:(OCLTerm *)term
{
    if((self = [super init])) {
        PrefixQuery *query = _CLNEW PrefixQuery([term cppTerm]);
        [self setCPPQuery:query];
        term_ = term;
    }
    return self;
}

@end
