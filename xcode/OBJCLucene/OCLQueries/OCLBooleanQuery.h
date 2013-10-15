//
//  OCLBooleanQuery.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLQuery.h"
#import "OCLBooleanClause.h"

@interface OCLBooleanQuery : OCLQuery

@property (nonatomic, readonly) NSArray *booleanClauses;

- (id)initWithClauses:(NSArray *)booleanClauses;

- (void)addClause:(OCLBooleanClause *)booleanClause;
- (void)addQuery:(OCLQuery *)query occur:(OCLBooleanClauseOccur)occur;

@end
