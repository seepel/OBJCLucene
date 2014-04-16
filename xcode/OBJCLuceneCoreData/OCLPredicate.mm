//
//  OCLPredicate.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/10/14.
//
//

#import "OCLPredicate.h"
#include "CLucene.h"
#import "NSString+OCL.h"
#import "NumericUtils.h"
#import "NumberTools.h"
#import "OCLQueryPrivate.h"

using namespace lucene::search;
using namespace lucene::queryParser;
using namespace lucene::analysis;
using namespace lucene::document;
using namespace ocl;

NSString * const OCLPredicateCanNotParse = @"OCLPredicateCanNotParse";

#define MAKE_UNICHAR(x) [@"x" characterAtIndex:0]

@interface OCLPredicate () {
    Analyzer *_analyzer;
}

@property (nonatomic, strong) NSString *queryString;
@property (nonatomic, readwrite) OCLQuery *query;

@end

@implementation OCLPredicate

+ (id)predicateWithFormat:(NSString *)format, ...
{
    va_list argList;
    va_start(argList, format);
    id predicate = [self predicateWithFormat:format arguments:argList];
    va_end(argList);
    return predicate;
}

+ (id)predicateWithFormat:(NSString *)format arguments:(va_list)argList
{
    NSCharacterSet *controlCodes = [NSCharacterSet characterSetWithCharactersInString:@"lfFdD@kK"];
    NSScanner *scanner = [[NSScanner alloc] initWithString:format];
    NSMutableString *queryString = [NSMutableString string];
    while (!scanner.isAtEnd) {
        NSString *tmp = nil;
        [scanner scanUpToString:@"%" intoString:&tmp];
        if(scanner.isAtEnd) {
            if(tmp != nil) {
                [queryString appendString:tmp];
            }
            break;
        }
        if(tmp != nil) {
            [queryString appendString:tmp];
        }
        tmp = nil;
        scanner.scanLocation++;
        [scanner scanCharactersFromSet:controlCodes intoString:&tmp];
        if([tmp isEqualToString:@"f"] || [tmp isEqualToString:@"F"] || [tmp isEqualToString:@"lf"] || [tmp isEqualToString:@"lF"] || [tmp isEqualToString:@"Lf"] || [tmp isEqualToString:@"LF"]) {
            double value = va_arg(argList, double);
            [queryString appendString:[NSString stringFromTCHAR:NumberTools::longToString(NumericUtils::doubleToSortableLong(value))]];
        } else if([tmp isEqualToString:@"d"] || [tmp isEqualToString:@"D"]) {
            int64_t value = va_arg(argList, int);
            [queryString appendString:@"\""];
            [queryString appendString:[NSString stringFromTCHAR:NumberTools::longToString(value)]];
            [queryString appendString:@"\""];
        } else if([tmp isEqualToString:@"k"] || [tmp isEqualToString:@"K"]) {
            NSString *value = va_arg(argList, NSString *);
            if(![value isKindOfClass:[NSString class]]) {
                [self throwInvalidFormatException:format];
            }
            [queryString appendString:value];
        } else if([tmp isEqualToString:@"@"]) {
            id object = va_arg(argList, id);
            if([object isKindOfClass:[NSString class]]) {
                [queryString appendString:object];
            } else if([object isKindOfClass:[NSNumber class]]) {
                const char *encoding = [object objCType];
                if(strcmp(encoding, @encode(double)) == 0 || strcmp(encoding, @encode(float)) == 0) {
                    [queryString appendString:[NSString stringFromTCHAR:NumberTools::longToString(NumericUtils::doubleToSortableLong([object doubleValue]))]];
                } else {
                    [queryString appendString:[NSString stringFromTCHAR:NumberTools::longToString([object longLongValue])]];
                }
            } else if([object isKindOfClass:[NSDate class]]) {
                [queryString appendString:[NSString stringFromTCHAR:NumberTools::longToString(NumericUtils::doubleToSortableLong([object timeIntervalSince1970]))]];
            } else {
                [self throwInvalidFormatException:format];
            }
        }
        tmp = nil;
    }
    return [[self alloc] initWithQueryString:queryString];
}

+ (void)throwInvalidFormatException:(NSString *)format
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Unable to parse the format string \"%@\"", format] userInfo:nil];

}

+ (id)predicateWithFormat:(NSString *)format argumentArray:(NSArray *)arguments
{
    return [super predicateWithFormat:format argumentArray:arguments];
}

- (id)initWithQueryString:(NSString *)queryString
{
    if((self = [super init])) {
        _queryString = queryString;
    }
    return self;
}

- (void)materializeWithAnalyzer:(Analyzer *)analyzer
{
    QueryParser *parser = _CLNEW QueryParser([@"_id" toTCHAR], analyzer);
    Query *query = parser->parse([self.queryString toTCHAR]);
    OCLQuery *oclQuery = [[OCLQuery alloc] init];
    [oclQuery setCPPQuery:query];
    self.query = oclQuery;
}

- (id)initWithQuery:(OCLQuery *)query filter:(OCLFilter *)filter
{
    if((self = [super init])) {
        _query = query;
        _filter = filter;
    }

    return self;
}

- (NSString *)description
{
    return self.queryString;
}

@end
