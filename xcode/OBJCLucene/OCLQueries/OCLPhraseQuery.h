//
//  OCLPhraseQuery.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLQuery.h"

@interface OCLPhraseQuery : OCLQuery

@property (nonatomic) int32_t slop;

- (id)initWithTerms:(NSArray *)terms slop:(int32_t)slop;

@end
