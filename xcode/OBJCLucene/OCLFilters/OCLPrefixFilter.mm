//
//  OCLPrefixFilter.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLPrefixFilter.h"
#import "OCLFilterPrivate.h"
#import "OCLTermPrivate.h"
#import "PrefixQuery.h"
#import "CachingWrapperFilter.h"

@interface OCLPrefixFilter ( ) {
    OCLTerm *term_;
}

@end

@implementation OCLPrefixFilter

@synthesize term = term_;

- (id)initWithTerm:(OCLTerm *)term
{
    return [self initWithTerm:term cache:NO];
}

- (id)initWithTerm:(OCLTerm *)term cache:(BOOL)cache;
{
    if((self = [super init])) {
        term_ = term;
        PrefixFilter *filter = _CLNEW PrefixFilter([term cppTerm]);
        if(cache) {
            CachingWrapperFilter *cachingFilter = _CLNEW CachingWrapperFilter(filter);
            [self setCPPFilter:cachingFilter];
        } else {
            [self setCPPFilter:filter];
        }
    }
    return self;
}

@end
