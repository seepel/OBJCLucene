//
//  OCLTermQuery.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLQuery.h"

@interface OCLTermQuery : OCLQuery

@property (nonatomic, readonly) OCLTerm *term;

- (id)initWithTerm:(OCLTerm *)term;

@end
