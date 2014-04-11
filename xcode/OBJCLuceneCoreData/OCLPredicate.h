//
//  OCLPredicate.h
//  OBJCLucene
//
//  Created by Sean Lynch on 4/10/14.
//
//

#import <Foundation/Foundation.h>
#import "OCLQuery.h"
#import "OCLFilter.h"
#import "CLucene.h"

@interface OCLPredicate : NSPredicate

@property (nonatomic, readonly) OCLQuery *query;
@property (nonatomic, readonly) OCLFilter *filter;

- (instancetype)initWithQuery:(OCLQuery *)query filter:(OCLFilter *)filter;
- (void)materializeWithAnalyzer:(lucene::analysis::Analyzer *)analyzer;

@end
