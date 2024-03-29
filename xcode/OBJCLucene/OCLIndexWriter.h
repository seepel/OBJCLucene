//
//  OCLIndexWriter.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@class OCLDocument;

/**
 @class OCLIndexWriter
 @abstract Writes and creates a search index
 @discussion Given a file path, OCLIndexWriter will create and write a index to the given path based on what OCLDocuments are added.  You should call -flush or -optimize once you are done to force a write to disk.
 @author  Bob Van Osten
 @version 1.0
 */
@interface OCLIndexWriter : NSObject

/**
 @method initWithPath:overwrite:stopWords:
 @abstract Returns an initialized OCLIndexWriter at a given path.
 @param inPath The path that the index should be written to
 @param inOverwrite A BOOL indicating whether the writer should over write an index that already exists at the specified path.
 @discussion This method will create an OCLIndexWriter with a default dictionary of english stop words that should not be indexed when writing documents. 
 @see initWithPath:overwrite:stopWords:
 @result An initialized OCLIndexWriter at a given path, using a specified dictionary of stop words.
 */
- (id)initWithPath:(NSString *)inPath overwrite:(BOOL)inOverwrite;

/**
 @method initWithPath:overwrite:stopWords:
 @abstract Returns an initialized OCLIndexWriter at a given path, using a specified dictionary of stop words.
 @param inPath The path that the index should be written to
 @param inOverwrite A BOOL indicating whether the writer should over write an index that already exists at the specified path.
 @param inStopWords An array of words that should be skipped when indexing documents. Passing nil will result in a defualt dictionary of english stop words. Passing an empty array will specify that no stop words should be used.
 @result An initialized OCLIndexWriter at a given path, using a specified dictionary of stop words.
 */
- (id)initWithPath:(NSString *)inPath overwrite:(BOOL)inOverwrite stopWords:(NSArray *)inStopWords;

@property (nonatomic, assign) int32_t   maxFieldLength;
@property (nonatomic, assign) BOOL      useCompoundFile;

@property (readonly) NSString *path;

/**
 @method addDocument:
 @abstract Adds a document to the index
 @discussion The document may not be ready for serching immediately, you should call optimize: once all documents have been added.  The reference to the OCLDocument is not stored or retained by the index, just the data in the document is added to the index.  The same document instance can be added more than once.
 @param inDocument An OCLDocument, the document is not retained by OCLIndexWriter
 */
- (void)addDocument:(OCLDocument *)inDocument;

/**
 @method removeDocumentsWithFieldForKey:matchingValue:
 @abstract Removes all the documents given a field key and value
 @discussion Given a field key and a matching value, the index writer will remove all the related documents.
 @param inFieldKey The key of a field to lookup
 @param inValue The value of the field to check against
 */
- (void)removeDocumentsWithFieldForKey:(NSString *)inFieldKey matchingValue:(NSString *)inValue;

/**
 @method replaceDocumentsWithFieldForKey:matchingValue:withDocument:
 @abstract Removes all the documents with a given field key and value and replaces it with the given document
 @discussion This performs the same action as calling removeDocumentsWithFieldName:matchingValue: and then addDocument:
 @param inFieldKey The key of a field to lookup
 @param inValue The value of the field to check against
 @param inDocument The document to add the the index once the found ones have been removed
 */
- (void)replaceDocumentsWithFieldForKey:(NSString *)inFieldKey matchingValue:(NSString *)inValue withDocument:(OCLDocument *)inDocument;

/**
 @method flush
 @abstract Flushes all documents to the index
 @discussion The documents will be written to the index and stored on disk once this is called
 */
- (void)flush;

/**
 @method optimize:
 @abstract Flushes and optimizes the index for faster searching
 @discussion Saves all documents to the index and performs internal optimizations for faster searching
 @param inWaitUntilDone If YES, will block until the optimization is finished, otherwise will perform the work on a background thread
 */
- (void)optimize:(BOOL)inWaitUntilDone;

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

@end
