//
//  OCLBooleanClausePrivate.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLBooleanClause.h"

@interface OCLBooleanClause (Private)

- (void)setCPPBooleanClause:(BooleanClause *)cppBooleanClause;
- (BooleanClause *)cppBooleanClause;

@end