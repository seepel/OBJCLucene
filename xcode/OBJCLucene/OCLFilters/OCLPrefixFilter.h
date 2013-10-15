//
//  OCLPrefixFilter.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLFilter.h"
#import "OCLTerm.h"

@interface OCLPrefixFilter : OCLFilter

@property (nonatomic, readonly) OCLTerm *term;

- (id)initWithTerm:(OCLTerm *)term;
- (id)initWithTerm:(OCLTerm *)term cache:(BOOL)cache;

@end
