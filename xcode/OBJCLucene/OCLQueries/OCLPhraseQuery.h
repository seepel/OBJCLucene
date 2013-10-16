//
//  OCLPhraseQuery.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLQuery.h"

/**
 @class OCLPhraseQuery
 @abstract An OCLPhraseQuery is an OCLQuery that is designed to match a sequence of terms, such as "new york"
 @discussion 
 @author Sean Lynch
 @version 1.0
 */
@interface OCLPhraseQuery : OCLQuery

@property (nonatomic) int32_t slop;

/**
 @method initWithTerms:slop:
 @abstract Returns an initialized OCLPhraseQuery with the specified OCLTerms and slop
 @param terms An NSArray of OCLTerms that specify the sequence of terms the query should match.
 @param slop An int32_t that specifies how many position changes can take place before a field value will no longer match the query
 @discussion All terms added must have the same field key.
 @result An initialized OCLPhraseQuery with the specified OCLTerms and slop
 */
- (id)initWithTerms:(NSArray *)terms slop:(int32_t)slop;

/**
 @method addTerm:
 @abstract Adds an OCLTerm to the sequence of terms to be matched by the query.
 @param term The OCLTerm to be added to the query
 @discussion The term's field key must be the same as those given in the initializer
 */
- (void)addTerm:(OCLTerm *)term;

@end
