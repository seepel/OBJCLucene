//
//  OCLWildCardQuery.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLQuery.h"

@interface OCLWildcardQuery : OCLQuery

@property (nonatomic, readonly) OCLTerm *term;

- (id)initWithTerm:(OCLTerm *)term;

@end
