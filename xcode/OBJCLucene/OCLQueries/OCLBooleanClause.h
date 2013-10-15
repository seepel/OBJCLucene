//
//  OCLBooleanClause.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import <Foundation/Foundation.h>

@class OCLQuery;

typedef enum {
    OCLBooleanClauseMustOccur = 1,
    OCLBooleanClauseShouldOccur = 2,
    OCLBooleanClauseMustNotOccur = 4
} OCLBooleanClauseOccur;

@interface OCLBooleanClause : NSObject

@property (nonatomic, strong) OCLQuery *query;
@property (nonatomic) OCLBooleanClauseOccur occur;

- (id)initWithQuery:(OCLQuery *)query occur:(OCLBooleanClauseOccur)occur;

@end
