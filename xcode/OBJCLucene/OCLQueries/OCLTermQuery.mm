//
//  OCLTermQuery.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLTermQuery.h"
#import "OCLQueryPrivate.h"
#import "OCLTermPrivate.h"
#import "TermQuery.h"

@interface OCLTermQuery () {
    OCLTerm *_term;
}

@end

@implementation OCLTermQuery

@synthesize term = term_;

- (id)initWithTerm:(OCLTerm *)term
{
    if((self = [super init])) {
        term_ = term;
        TermQuery *query = _CLNEW TermQuery(term.cppTerm);
        [self setCPPQuery:query];
    }
    return self;
}


@end
