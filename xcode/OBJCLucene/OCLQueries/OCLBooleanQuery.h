//
//  OCLBooleanQuery.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLQuery.h"
#import "OCLBooleanClause.h"

/**
 @class OCLBooleanQuery
 @abstract An OCLQuery that will merge several other OCLQueries together.
 @discussion
 @author Sean Lynch
 @version 1.0
 */
@interface OCLBooleanQuery : OCLQuery

@property (nonatomic, readonly) NSArray *booleanClauses;

/**
 @method initWithClauses:
 @abstract Returns an initialized OCLBooleanQuery configured with the given OCLBooleanClauses
 @param clauses An NSArray of OCLBooleanClauses
 @discussion
 @result An initialized  OCLBooleanQuery configured with the given OCLBooleanClauses
 */
- (id)initWithClauses:(NSArray *)booleanClauses;

/**
 @method addClause:
 @abstract Adds a OCLBooleanClause to the query
 @param booleanClause The OCLBooleanClause to add to the query
 */
- (void)addClause:(OCLBooleanClause *)booleanClause;

/**
 @method addQuery:occur:
 @abstract Creats and adds an OCLBooleanClause to the query for the given OCLQuery and OCLBooleanClauseOccur
 @param query The OCLQuery to add as a subquery
 @param occur The OCLBooleanClauseOccur specifying whether the given query must match, must not match, or should match.
 */
- (void)addQuery:(OCLQuery *)query occur:(OCLBooleanClauseOccur)occur;

@end
