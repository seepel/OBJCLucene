//
//  OCLQueryParser.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@class OCLQuery;

/**
 @class OCLQueryParser
 @abstract Parses query string and creates a usable OCLQuery
 @discussion Parses a properly escaped lucene formatted query string for a given field
 @author  Bob Van Osten
 @version 1.0
 */
@interface OCLQueryParser : NSObject

@property (strong) NSString *queryString;

@property (nonatomic, assign) float     fuzzyMinSim;
@property (nonatomic, assign) int       fuzzyPrefixLength;
@property (nonatomic, assign) int       phraseSlop;
@property (nonatomic, assign) BOOL      allowLeadingWildcard;

/**
 @method initWithQueryString:forFieldKey:
 @abstract Initialize a QueryParser given a query string and field
 @discussion The query string needs to be properly escaped, and the given field key will be what is searched.
 @param inString An escaped lucene formatted query string
 @param inField A key represnting the field to the searched
 */
- (id)initWithQueryString:(NSString *)inString forFieldKey:(NSString *)inField;

/**
 @method query
 @abstract Returns an OCLQuery object that can be used to search
 @result A OCLQuery object
 */
- (OCLQuery *)query;

/**
 @method escapeString:
 @abstract Escapes a given string
 @discussion This should be used to escape search terms given by the user, it will escape \+-!():^[]"{}~*?|&
 @param inString A non-escaped string, typically what is given by the user
 @result An escaped string
 */
+ (NSString *)escapeString:(NSString *)inString;

@end
