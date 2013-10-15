//
//  OCLFilter.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLFilter.h"
#import "OCLFilterPrivate.h"
#import "OCLQueryPrivate.h"
#import "QueryFilter.h"
#import "CachingWrapperFilter.h"

@interface OCLFilter ( ) {
    OCLQuery *query_;
    Filter *cppFilter_;
}

@end

@implementation OCLFilter

@synthesize query = query_;

- (id)initWithQuery:(OCLQuery *)query
{
    return [self initWithQuery:query cache:NO];
}
- (id)initWithQuery:(OCLQuery *)query cache:(BOOL)cache
{
    if((self = [super init])) {
        query_ = query;
        QueryFilter *filter = _CLNEW QueryFilter([query cppQuery], false);
        if(cache) {
            CachingWrapperFilter *cachingFilter = _CLNEW CachingWrapperFilter(filter);
            [self setCPPFilter:cachingFilter];
        } else {
            [self setCPPFilter:filter];
        }
    }
    return self;
}

- (void)setCPPFilter:(lucene::search::Filter *)filter
{
    if(cppFilter_ != NULL) {
        _CLVDELETE(cppFilter_);
    }
    cppFilter_ = filter;
}

- (lucene::search::Filter *)cppFilter
{
    return cppFilter_;
}

@end
