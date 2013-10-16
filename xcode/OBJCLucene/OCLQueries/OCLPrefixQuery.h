//
//  OCLPrefixQuery.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLQuery.h"

/**
 @class OCLPrefixQuery
 @abstract The OCLPrefixQuery is designed to match field values with the form "Rel*" which would match both RelateIQ and  Related
 @discussion When an OCLPrefixQuery is used, it is rewritten into a Boolean query by expanding it's term to all possible values.
 This can become very large and exceed the number of allowed terms for a boolean query.
 @author Sean Lynch
 @version 1.0
 */
@interface OCLPrefixQuery : OCLQuery

@property (nonatomic, readonly) OCLTerm *term;

/**
 @method initWithTerm:
 @abstract Returns an initialized OCLPrefixQuery using the given OCLTerm as the prefix to match
 @param term An OCLTerm representing the prefix that should be matched.
 @result An initialized OCLPrefixQuery using the given OCLTerm as the prefix to match
 */
- (id)initWithTerm:(OCLTerm *)term;

@end
