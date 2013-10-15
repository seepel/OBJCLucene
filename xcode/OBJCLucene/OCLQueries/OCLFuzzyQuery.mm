//
//  OCLFuzzyQuery.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLFuzzyQuery.h"
#import "OCLQueryPrivate.h"
#import "OCLTermPrivate.h"
#import "FuzzyQuery.h"

@interface OCLFuzzyQuery ( ) {
    OCLTerm *term_;
    float minimumSimilarity_;
    NSUInteger prefixLength_;
}

@end

@implementation OCLFuzzyQuery

- (id)initWithTerm:(OCLTerm *)term minimumSimilarity:(float)minimumSimilarity prefixLength:(NSUInteger)prefixLength
{
    if((self = [super init])) {
        term_ = term;
        minimumSimilarity_ = minimumSimilarity;
        prefixLength_ = prefixLength;
        FuzzyQuery *query = _CLNEW FuzzyQuery([term cppTerm], minimumSimilarity, (size_t)prefixLength);
        [self setCPPQuery:query];
    }
    return self;
}

@end
