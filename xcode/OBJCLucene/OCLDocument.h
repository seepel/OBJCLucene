//
//  OCLDocument.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@class OCLField;

/**
 @class OCLDocument
 @abstract A document represents a group of fields in an index
 @discussion A document is an object that represents a set of fields that can be retrieved when a search result is found. It can be retrieved from a OCLIndexReader or stored with OCLIndexWriter. Its meant to be used as a resuable object. The index reader and writer do not store these, they just put or get data from it.
 @author  Bob Van Osten
 @version 1.0
 */
@interface OCLDocument : NSObject

@property (nonatomic) float boost;

/**
 @method addFieldForKey:value:tokenized:
 @abstract Adds a field to the document that may be searched
 @discussion Use this to add key/values to the document, where the value is what is searched and the key can be used to represent the object.  Set tokenized to YES if you want the value to be indexed for searching.
 @param inKey A key to represent the field
 @param inValue A value to be used for searching
 @param inTokenized Set to YES if this field should be indexed for searching
 */
- (void)addFieldForKey:(NSString *)inKey value:(NSString *)inValue tokenized:(BOOL)inTokenized;

/**
 @method fieldForKey:
 @abstract Retrieves a field given a key
 @discussion Returns an OCLField object that holds the key/value data.  A new OCLField instance is returned each time.
 @param inKey A key that represents the desired field
 @result A OCLField given a key
 */
- (OCLField *)fieldForKey:(NSString *)inKey;

/**
 @method removeFieldForKey:
 @abstract Removes a field given a key
 @discussion Removes a field given a key, this is only useful before the document is added to an index.  If called after, the data will remain indexed, in this case you need to remove the document and re-add it.
 @param inKey A key that represents the desired field
 */
- (void)removeFieldForKey:(NSString *)inKey;

/**
 @method clear
 @abstract Removes all the fields in a document
 @discussion Removes all the fields, this is useful to be able to reuse the document when adding lots of data to an index.  The same instance can be added to an index more than once.
 @param inKey A key that represents the desired field
 */
- (void)clear;

@end
