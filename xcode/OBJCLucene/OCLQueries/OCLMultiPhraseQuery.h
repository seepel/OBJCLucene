//
//  OCLMultiPhraseQuery.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLQuery.h"

/**
 @class OCLMultiPhraseQuery
 @abstract OCLMultiPhraseQuery in its current implementation is essentially the same as OCLPhraseQuery. 
 @discussion In the future this class will be expanded to include
 - (void)addTerms:(NSArray*)terms
 Allowing one to match terms such as "RelateIQ app*"
 @author Sean Lynch
 @version 1.0
 */
@interface OCLMultiPhraseQuery : OCLQuery

@property (nonatomic) int32_t slop;

/**
 @method initWithTerms:slop:
 @abstract Returns an initialized OCLMultiPhraseQuery with the given terms and slop
 @param terms An array of OCLTerms to initialize  the OCLMultiPhraseQuery with
 @param slop An int32_t used to specify how many position swaps are allowed before a field value will no longer match.
 @discussion The result of this method is identical to the initializer for OCLPhraseQuery
 @result An initialized OCLMultiPhraseQuery
 */
- (id)initWithTerms:(NSArray *)terms slop:(int32_t)slop;

/**
 @method addTerm:
 @abstract Adds an OCLTerm to the query
 @param term An OCLTerm to be added to the query
 @discussion This method performs identically to the same method signature on OCLPhraseQuery
 */
- (void)addTerm:(OCLTerm *)term;

@end
