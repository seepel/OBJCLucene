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

/**
 @class OCLIndexSearcher
 @abstrat An OCLIndexSearcher is a class that can be used to perform searches using an OCLQuery and optionally an OCLFilter
 @author Sean Lynch
 @version 1.0
 */
@interface OCLIndexSearcher : NSObject

/**
 @method initWithIndexReader:(OCLIndexReader *)indexReader
 @abstract Returns an initialized OCLIndexSearcher with the given index reader
 @param indexReader An OCLIndexReader that the searcher should use to perform its search
 @result An initialized OCLIndexSearcher with the given index reader
 */
- (id)initWithIndexReader:(OCLIndexReader *)indexReader;

/**
 @method search:
 @abstract Performs a search configured by the given query.
 @param query An OCLQuery that will be used to match documents in the index for the search
 @discussion The returned NSArray will lazy load matched documents, so it is advisable to avoid iterating through the entire array if all matching documents are not needed. If you are simply interested in optaining the values for a single field (for example a unique ID). There is a convenience method on OCLQuery - findFieldValuesForKey:withIndex:
 @result An NSArray that will lazy load matched documents as they are accessed.
 */
- (NSArray *)search:(OCLQuery *)query;

/**
 @method search:
 @abstract Performs a search configured by the given query.
 @param query An OCLQuery that will be used to match documents in the index for the search
 @discussion The returned NSArray will lazy load matched documents, so it is advisable to avoid iterating through the entire array if all matching documents are not needed. In the future OBJCLucene may be extended to support Hit Collectors for mor performant parsing of large numbers of document results.
 @result An NSArray that will lazy load matched documents as they are accessed.
 */
- (NSArray *)search:(OCLQuery *)query filter:(OCLFilter *)filter;

@end
