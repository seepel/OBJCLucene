//
//  OCLFuzzyQuery.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLQuery.h"

@interface OCLFuzzyQuery : OCLQuery

@property (nonatomic, readonly) OCLTerm *term;
@property (nonatomic, readonly) float minimumSimilarity;
@property (nonatomic, readonly) NSUInteger prefixLength;

- (id)initWithTerm:(OCLTerm *)term minimumSimilarity:(float)minimumSimilarity prefixLength:(NSUInteger)prefixLength;

@end
