//
//  OCLIndexReader.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@class OCLDocument;
@class OCLTerm;

/**
 @class OCLIndexReader
 @abstract A index that can be read and searched
 @discussion An index reader is used for reading an existing index and also used for searching
 @author  Bob Van Osten
 @version 1.0
 */
@interface OCLIndexReader : NSObject

@property (readonly) NSString *path;

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
 @method removeDocumentsWithFieldForKey:matchingValue:
 @abstract Removes all the documents given a field key and value
 @discussion Given a field key and a matching value, the index writer will remove all the related documents.
 @param inFieldKey The key of a field to lookup
 @param inValue The value of the field to check against
 @result The number of documents deleted
 */
- (NSInteger)removeDocumentsWithFieldForKey:(NSString *)inFieldKey matchingValue:(NSString *)inValue;

/**
 @method removeDocumentsWithFieldForKey:matchingValue:
 @abstract Removes all the documents given a field key and value
 @discussion Given a field key and a matching value, the index writer will remove all the related documents.
 @param inFieldKey The key of a field to lookup
 @param inValue An array of value of the field to check against
 @result The number of documents deleted
 */
- (NSInteger)removeDocumentsWithFieldForKey:(NSString *)inFieldKey matchingValues:(NSArray *)inValues;

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

/**
 @method close
 @abstract Closes the index to be read by another reader/writer
 @discussion Once closed documents can not be added to the index
 */
- (void)close;

/**
 @method open
 @abstract Opens the index to be read
 @discussion Opens the index so documents can be added to the index
 */
- (BOOL)open;


/**
 @method terms
 @abstract Returns all terms in the index.
 @result A sorted NSArray containing all terms that are in the index
 */
- (NSArray *)terms;

/**
 @method terms:
 @abstract Returns an enumeration of all terms starting at a given term. If the given term does not exist, the enumeration is positioned at the first term greater than the supplied therm. The enumeration is ordered by Term.compareTo(). Each term is greater than all that precede it in the enumeration.
 @param term The OCLTerm to start the enumeration at
 @result A sorted NSArray containing all terms that are greater than or equal to the given term
 */
- (NSArray *)terms:(OCLTerm *)term;

@end
