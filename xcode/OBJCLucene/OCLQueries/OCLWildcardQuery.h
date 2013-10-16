//
//  OCLWildCardQuery.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLQuery.h"

/**
 @class OCLWildecardQuery
 @abstract OCLWildcardQuery is a query that will match documents using the familiar unix style wildcards
 @discussion  Supported wildcards are *, which matches any character sequence (including the empty one), and ?, which matches any single character. Note this query can be slow, as it needs to iterate over many terms. In order to prevent extremely slow WildcardQueries, a Wildcard term should not start with one of the wildcards * or ?.
 @author Sean Lynch
 @version 1.0
 */
@interface OCLWildcardQuery : OCLQuery

@property (nonatomic, readonly) OCLTerm *term;

/**
 @method initWithTerm:
 @abstract Returns an initialized OCLWildcardQuery with the given OCLTerm
 @param term The OCLTerm to be matched by the query
 @discussion  Supported wildcards are *, which matches any character sequence (including the empty one), and ?, which matches any single character. Note this query can be slow, as it needs to iterate over many terms. In order to prevent extremely slow WildcardQueries, a Wildcard term should not start with one of the wildcards * or ?.
 @result An initialized OCLWildcardQuery with the given OCLTerm
 */
- (id)initWithTerm:(OCLTerm *)term;

@end
