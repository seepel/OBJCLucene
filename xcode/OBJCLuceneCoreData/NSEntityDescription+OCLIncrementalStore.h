//
//  NSEntityDescription+OCLIncrementalStore.h
//  OBJCLucene
//
//  Created by Sean Lynch on 4/8/14.
//
//

#import <CoreData/CoreData.h>
#import "CLucene.h"

extern NSString * const OCLAttributeForObjectId;

@interface NSEntityDescription (OCLIncrementalStore)

- (NSString *)attributeNameForObjectId;
- (lucene::search::Query *)queryForPredicate:(NSPredicate *)predicate indexReader:(lucene::index::IndexReader *)indexReader analyzer:(lucene::analysis::Analyzer *)analyzer;

@end
