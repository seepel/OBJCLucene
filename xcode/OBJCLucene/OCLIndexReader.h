//
//  OCLIndexReader.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@class OCLDocument;

/**
 @class OCLIndexReader
 @abstract A index that can be read and searched
 @discussion An index reader is used for reading an existing index and also used for searching
 @author  Bob Van Osten
 @version 1.0
 */
@interface OCLIndexReader : NSObject

/**
 @method initWithPath:
 @abstract Initialize an index reader
 @discussion Will create a reader if an index at the given path exists
 @param inPath A file path to a index
 */
- (id)initWithPath:(NSString *)inPath;

/**
 @method numberOfDocuments
 @abstract Returns the number of documents in the index
 @result A NSUInteger representing the number of documents
 */
- (NSUInteger)numberOfDocuments;

/**
 @method documentAtIndex:
 @abstract Returns a document at a given index
 @discussion The returned document at the same index will not be the same instance, a new instance is created each time.
 @result A new OCLDocument with the correct fields populated
 */
- (OCLDocument *)documentAtIndex:(NSInteger)inIndex;

/**
 @method unlockIndexAtPath
 @abstract Unlocks an index with a given path
 @discussion If there was a crash and the index lock was not removed, call this to force deletion of the lock
 @param inPath The path of the index directory
 */
+ (void)unlockIndexAtPath:(NSString *)inPath;

/**
 @method indexAtPathIsLocked:
 @abstract Determines if an index at path is locked
 @discussion If the index at the given path is in use or the app crashed during use, will return YES
 @param inPath The path of the index directory
 */
+ (BOOL)indexAtPathIsLocked:(NSString *)inPath;

@end
