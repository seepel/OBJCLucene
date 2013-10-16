//
//  OCLFuzzyQuery.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLQuery.h"

/**
 @class OCLFuzzyQuery
 @abstract An OCLFuzzyQuery is an OCLQuery that allows a certain amount of flexibility in matching to its term
 @discussion
 @author Sean Lynch
 @version 1.0
 */
@interface OCLFuzzyQuery : OCLQuery

@property (nonatomic, readonly) OCLTerm *term;
@property (nonatomic, readonly) float minimumSimilarity;
@property (nonatomic, readonly) NSUInteger prefixLength;

/**
 @method initWithTerm:minimumSimilarity:prefixLength
 @abstract Returns an initialized OCLFuzzyQuery with the given term, a minimum similarity to match and a prefixLength
 @param term An OCLTerm representing the field and value to match
 @param minimumSimilarity A float that specify how closely a field value must match the term to pass the query condition.
 @param prefixLength An NSUInteger representing the number of characters that must match exactly at the beginning of the field value
 @discussion The similarity measurement is based on the Levenshtein (edit distance) algorithm 
 @result An initialized OCLFuzzyQuery with the given term, a minimum similarity to match and a prefixLength
 */
- (id)initWithTerm:(OCLTerm *)term minimumSimilarity:(float)minimumSimilarity prefixLength:(NSUInteger)prefixLength;

@end
