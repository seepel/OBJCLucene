//
//  OCLTermQuery.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLQuery.h"

/**
 @class OCLTermQuery
 @abstract An OCLTermQuery is an OCLQuery that must match a given term exactly.
 @discussion
 @author Sean Lynch
 @version 1.0
 */
@interface OCLTermQuery : OCLQuery

@property (nonatomic, readonly) OCLTerm *term;

/**
 @method initWithTerm:
 @abstract Returns an initialized OCLTermQuery for the given OCLTerm
 @param term An OCLTerm that a document must match exactly to be returned from a search.
 @result An initialized OCLTermQuery for the given OCLTerm
 */
- (id)initWithTerm:(OCLTerm *)term;

@end
