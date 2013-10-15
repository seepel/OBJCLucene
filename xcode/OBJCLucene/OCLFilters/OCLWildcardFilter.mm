//
//  OCLWildcardFilter.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLWildcardFilter.h"
#import "OCLFilterPrivate.h"
#import "OCLTermPrivate.h"
#import "WildcardQuery.h"
#import "CachingWrapperFilter.h"

@interface OCLWildcardFilter ( ) {
    OCLTerm *term_;
}

@end

@implementation OCLWildcardFilter

@synthesize term = term_;

- (id)initWithTerm:(OCLTerm *)term cache:(BOOL)cache;
{
    if((self = [super init])) {
        term_ = term;
        WildcardFilter *filter = _CLNEW WildcardFilter([term cppTerm]);
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
