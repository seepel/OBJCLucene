//
//  OCLBooleanClause.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import <Foundation/Foundation.h>

@class OCLQuery;

typedef enum {
    OCLBooleanClauseMustOccur = 1,
    OCLBooleanClauseShouldOccur = 2,
    OCLBooleanClauseMustNotOccur = 4
} OCLBooleanClauseOccur;

/**
 @class OCLBooleanClause
 @abstract Wraps an OCLQuery for inclusion in an OCLBooleanQuery.
 @discussion
 @author Sean Lynch 
 @version 1.0
 */
@interface OCLBooleanClause : NSObject

@property (nonatomic, strong) OCLQuery *query;
@property (nonatomic) OCLBooleanClauseOccur occur;

/**
 @method initWithQuery:occur:
 @abstract Returns an initialized OCLBooleanClause containing the given OCLQuery and OCLBooleanClauseOccur
 @param query An OCLQuery to be included in the OCLBooleanClause
 @param occur An OCLBooleanClauseOccur specifying whether the query must match, must not match, or should match.
 @discussion
 @result An initialized OCLBooleanClause for the give OCLQuery and OCLBooleanClauseOccur
 */
- (id)initWithQuery:(OCLQuery *)query occur:(OCLBooleanClauseOccur)occur;

@end
