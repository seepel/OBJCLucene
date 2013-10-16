//
//  OCLIndexSearcher.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import <Foundation/Foundation.h>

@class OCLIndexReader;
@class OCLQuery;
@class OCLFilter;

@interface OCLIndexSearcher : NSObject

- (id)initWithIndexReader:(OCLIndexReader *)indexReader;

- (NSArray *)search:(OCLQuery *)query;
- (NSArray *)search:(OCLQuery *)query filter:(OCLFilter *)filter;

@end
