//
//  OCLQueryParser.m
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "OCLQueryParser.h"
#import "OCLQueryPrivate.h"
#import "NSString+OCL.h"

@implementation OCLQueryParser {
    QueryParser* _queryParser;
    standard::StandardAnalyzer _analyzer;
}

@synthesize fuzzyMinSim = _fuzzyMinSim;
@synthesize fuzzyPrefixLength = _fuzzyPrefixLength;
@synthesize phraseSlop = _phraseSlop;
@synthesize allowLeadingWildcard = _allowLeadingWildcard;

- (id)initWithQueryString:(NSString *)inString forFieldKey:(NSString *)inField
{
    if((self = [super init])) {
        _queryParser = _CLNEW QueryParser([inField toTCHAR], &_analyzer);
        self.queryString = inString;
    }
    
    return self;
}

- (void)dealloc
{
    _CLVDELETE(_queryParser);
}

- (OCLQuery *)query
{
    OCLQuery *query = [[OCLQuery alloc] init];
    
    [query setCPPQuery:_queryParser->parse([self.queryString toTCHAR])];
    
    return query;
}

+ (NSString *)escapeString:(NSString *)inString
{
    return [inString escapeForQuery];
}

- (void)setFuzzyMinSim:(float)fuzzyMinSim
{
    _queryParser->setFuzzyMinSim(fuzzyMinSim);
    _fuzzyMinSim = fuzzyMinSim;
}

- (void)setFuzzyPrefixLength:(int)fuzzyPrefixLength
{
    _queryParser->setFuzzyPrefixLength(fuzzyPrefixLength);
    _fuzzyPrefixLength = fuzzyPrefixLength;
}

- (void)setPhraseSlop:(int)phraseSlop
{
    _queryParser->setPhraseSlop(phraseSlop);
    _phraseSlop = phraseSlop;
}

- (void)setAllowLeadingWildcard:(BOOL)allowLeadingWildcard
{
    _queryParser->setAllowLeadingWildcard(allowLeadingWildcard);
    _allowLeadingWildcard = allowLeadingWildcard;
}


@end
