//
//  OCLQueryParser.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@class OCLQuery;

@interface OCLQueryParser : NSObject

@property (strong) NSString *queryString;

@property (nonatomic, assign) float     fuzzyMinSim;
@property (nonatomic, assign) int       fuzzyPrefixLength;
@property (nonatomic, assign) int       phraseSlop;
@property (nonatomic, assign) BOOL      allowLeadingWildcard;

- (id)initWithQueryString:(NSString *)inString forFieldName:(NSString *)inField;

- (OCLQuery *)query;

+ (NSString *)escapeString:(NSString *)inString;

@end
