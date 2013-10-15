//
//  OCLMultiPhraseQuery.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLQuery.h"

@interface OCLMultiPhraseQuery : OCLQuery

@property (nonatomic) int32_t slop;

- (id)initWithTerms:(NSArray *)terms slop:(int32_t)slop;

- (void)addTerm:(OCLTerm *)term;

@end
