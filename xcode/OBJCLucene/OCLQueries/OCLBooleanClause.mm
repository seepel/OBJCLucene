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

@interface OCLBooleanClause () {
    BooleanClause *cppBooleanClause_;
}

@end

@implementation OCLBooleanClause

@synthesize query = query_;
@synthesize occur = occur_;

- (id)initWithQuery:(OCLQuery *)query occur:(OCLBooleanClauseOccur)occur
{
    if((self = [super init])) {
        BooleanClause *booleanClause = _CLNEW BooleanClause([query cppQuery], false, (BooleanClause::Occur)occur);
        [self setCPPBooleanClause:booleanClause];
        query_ = query;
        occur_ = occur;
    }
    return self;
}

- (void)dealloc
{
//    if(cppBooleanClause_ != NULL) {
//        _CLVDELETE(cppBooleanClause_);
//    }
}

- (void)setCPPBooleanClause:(lucene::search::BooleanClause *)cppBooleanClause
{
    if(cppBooleanClause_ != NULL) {
        _CLVDELETE(cppBooleanClause_);
    }
    cppBooleanClause_ = cppBooleanClause;
}

- (BooleanClause *)cppBooleanClause
{
    return cppBooleanClause_;
}

- (void)setQuery:(OCLQuery *)query
{
    query_ = query;
    BooleanClause *cppBooleanClause = [self cppBooleanClause];
    if(cppBooleanClause != NULL) {
        cppBooleanClause->setQuery([query cppQuery]);
    }
}

- (void)setOccur:(OCLBooleanClauseOccur)occur
{
    occur_ = occur;
    BooleanClause *cppBooleanClause = [self cppBooleanClause];
    cppBooleanClause->setOccur((BooleanClause::Occur)occur);
}

@end
