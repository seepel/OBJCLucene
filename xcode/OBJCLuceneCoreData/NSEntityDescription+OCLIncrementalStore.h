//
//  NSEntityDescription+OCLIncrementalStore.h
//  OBJCLucene
//
//  Created by Sean Lynch on 4/8/14.
//
//

#import <CoreData/CoreData.h>
#import "CLucene.h"

@interface NSEntityDescription (OCLIncrementalStore)

- (lucene::search::Query *)queryForPredicate:(NSPredicate *)predicate indexReader:(lucene::index::IndexReader *)inIndexReader;

@end
