//
//  OCLQuery.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@class OCLIndexReader;

/**
 @class OCLQuery
 @abstract Searches an index
 @discussion Retrieved from OCLQueryParser, this will perform the actual search on an OCLIndexReader
 @author  Bob Van Osten
 @version 1.0
 */
@interface OCLQuery : NSObject

/**
 @method findDocumentsWithIndex:
 @abstract Returns a list of found OCLDocuments
 @discussion This will return an array of OCLDocuments sorted by search score, with the best result first. -findFieldValuesForKey:withIndex: will give better performance
 @param inReader A index to search
 @result An array of OCLDocuments
 */
- (NSArray *)findDocumentsWithIndex:(OCLIndexReader *)inReader;

/**
 @method findFieldValuesForKey:withIndex:
 @abstract Returns an array of string values from a given field in the found documents
 @discussion This returns just the desired field values instead of an entire document, performance for this is much better than findDocumentsWithIndex:, since the entire document does not need to be loaded in to memory.  The result is also sorted by the search score.
 @param inKey A key representing the desired field
 @param inReader A index to search
 @result An array of NSStrings
 */
- (NSArray *)findFieldValuesForKey:(NSString *)inKey withIndex:(OCLIndexReader *)inReader;

@end
