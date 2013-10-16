//
//  OCLQuery.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@class OCLIndexReader;
@class OCLFilter;
@class OCLTerm;

/**
 @class OCLQuery
 @abstract Searches an index
 @discussion Can be retrieved from an OCLQueryParser or created manually, this will perform the actual search on an OCLIndexReader
 @author  Bob Van Osten
 @version 1.0
 */
@interface OCLQuery : NSObject

@property (nonatomic) float boost;

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

/**
 @method booleanQueryWithClauses:
 @abstract Creates an OCLBooleanQuery
 @discussion
 @param inClauses An array of OCLBooleanClauses used to construct the query
 @result An initialized OCLQuery with a backing BooleanQuery
 */
+ (id)booleanQueryWithClauses:(NSArray *)inClauses;

// Not implemented
//+ (id)constantScoreQueryWithFilter:(OCLFilter *)filter;

/**
 @method fuzzyQueryWithTerm:minimumSimilarity:prefixLength:
 @abstract Returns an OCLQuery initialized with a backing FuzzyQuery
 @discussion
 @param inTerm An OCLTerm representing the field and text to be searched
 @param minimumSimilarity A float
 @param prefixLength
 @result An initialized OCLQuery with a backing FuzzyQuery
 */
+ (id)fuzzyQueryWithTerm:(OCLTerm *)term minimumSimilarity:(float)minimumSimilarity prefixLength:(NSUInteger)prefixLength;

/** 
 @method allDocsQuery
 @abstract Returns an OCLQuery with a backing MatchAllDocsQuery
 @result An initialized OCLQuery with a backing MatchAllDocsQuery
 */
+ (id)allDocsQuery;


/**
 @method multiPhraseQueryWithTerms:slop:
 @abstract Returns an OCLQuery with a backing MultiPhraseQuery
 @param terms An array of OCLTerms for phrases to be included in the MultiPhraseQuery
 @param slop An integer representing the number of 
 */
+ (id)multiPhraseQueryWithTerms:(NSArray *)terms slop:(NSUInteger)slop;

/**
 @method phraseQueryWithTerms:slop:
 @abstarct Returns an OCLPhraseQuery configured with the specified terms
 @param tecms an Array of OCLTerms for the phrase of the PhraseQuery
 @param slop An iinteger representing the number of
 @result An initalized OCLPhraseQuery configured with the specified terms
 */
+ (id)phraseQueryWithTerms:(NSArray *)terms slop:(NSUInteger)slop;

/**
 @method prefixQueryWithTerm:
 @abstract Creates an OCLPrefixQuery
 @param term An OCLTerm representing the desired prefix
 @result An OCLPrefixQuery
 */
+ (id)prefixQueryWithTerm:(OCLTerm *)term;

//+ (id)rangeQueryWithRange:(NSRange)range;
+ (id)termQueryWithTerm:(OCLTerm *)term;

+ (id)wildcardQueryWithTerm:(OCLTerm *)term;

@end
