//
//  OCLPredicateTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/10/14.
//
//

#import <XCTest/XCTest.h>
#import "OCLPredicate.h"
#import "OBJCLucene.h"
#import "NSString+OCL.h"
#import "NumericUtils.h"

using namespace ocl;
using namespace lucene::analysis;
using namespace lucene::analysis::standard;

@interface OCLPredicateTests : XCTestCase

@end

@implementation OCLPredicateTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSimpleFormat
{
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"test:\"Test\""];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:@"test" text:@"test" internField:YES]];
    StandardAnalyzer analyzer = StandardAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithSpace
{
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"test:\"Test test\""];
    OCLQuery *expected = [OCLPhraseQuery phraseQueryWithTerms:@[[[OCLTerm alloc] initWithField:@"test" text:@"test" internField:YES],
                                                                [[OCLTerm alloc] initWithField:@"test" text:@"test" internField:YES] ] slop:0];
    StandardAnalyzer analyzer = StandardAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithKeyPath
{
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:\"test\"", @"test"];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:@"test" text:@"test" internField:YES]];
    StandardAnalyzer analyzer = StandardAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithString
{
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:%@", @"test", @"test"];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:@"test" text:@"test" internField:YES]];
    StandardAnalyzer analyzer = StandardAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithInt
{
    NSString *keyPath = @"test";
    int value = 2;
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K: %d", keyPath, value];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString((int64_t)value)] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithUnsignedInt
{
    NSString *keyPath = @"test";
    unsigned int value = 1;
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K: %d", keyPath, value];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString((int64_t)value)] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithFloat
{
    NSString *keyPath = @"test";
    float value = 1.1;
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:%f", keyPath, value];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString(NumericUtils::doubleToSortableLong((double)value))] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithFloatFailAsDouble
{
    NSString *keyPath = @"test";
    double doubleValue = 1.1;
    float floatValue = 1.1;
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:%f", keyPath, floatValue];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString(NumericUtils::doubleToSortableLong(doubleValue))] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertNotEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithDouble
{
    NSString *keyPath = @"test";
    double value = 1.1;
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:%f", keyPath, value];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString(NumericUtils::doubleToSortableLong((double)value))] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithDoubleFailAsFloat
{
    NSString *keyPath = @"test";
    double doubleValue = 1.1;
    float floatValue = 1.1;
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:%f", keyPath, doubleValue];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString(NumericUtils::doubleToSortableLong((double)floatValue))] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertNotEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithDate
{
    NSString *keyPath = @"test";
    double timeInterval = 1397076225;
    id value = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:%@", keyPath, value];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString(NumericUtils::doubleToSortableLong(timeInterval))] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithIntegerNumber
{
    NSString *keyPath = @"test";
    NSInteger primitiveValue = 1;
    id value = @(primitiveValue);
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:%@", keyPath, value];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString(primitiveValue)] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testUnsignedIntegerNumber
{
    NSString *keyPath = @"test";
    NSUInteger primitiveValue = 1;
    id value = @(primitiveValue);
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:%@", keyPath, value];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString(primitiveValue)] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testUnsignedIntegerLargeNumber
{
    NSString *keyPath = @"test";
    NSUInteger primitiveValue = NSNotFound;
    id value = @(primitiveValue);
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:%@", keyPath, value];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString(primitiveValue)] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithFloatNumber
{
    NSString *keyPath = @"test";
    float primitiveValue = 1.1;
    id value = @(primitiveValue);
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:%@", keyPath, value];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString(NumericUtils::doubleToSortableLong((double)primitiveValue))] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithFloatNumberFailAsDouble
{
    NSString *keyPath = @"test";
    double doubleValue = 1.1;
    float floatValue = 1.1;
    id value = @(floatValue);
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:%f", keyPath, value];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString(NumericUtils::doubleToSortableLong(doubleValue))] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertNotEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithDoubleNumber
{
    NSString *keyPath = @"test";
    double primitiveValue = 1.1;
    id value = @(primitiveValue);
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:%@", keyPath, value];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString(NumericUtils::doubleToSortableLong(primitiveValue))] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertEqualObjects(predicate.query, expected, @"");
}

- (void)testFormatWithDoubleNumberFailAsFloat
{
    NSPredicate *falsePredicate = [NSPredicate predicateWithFormat:@"FALSEPREDICATE"];
    NSLog(@"predicate: %@", falsePredicate);
    NSString *keyPath = @"test";
    double doubleValue = 1.1;
    float floatValue = 1.1;
    id value = @(doubleValue);
    OCLPredicate *predicate = (OCLPredicate *)[OCLPredicate predicateWithFormat:@"%K:%@", keyPath, value];
    OCLQuery *expected = [OCLQuery termQueryWithTerm:[[OCLTerm alloc] initWithField:keyPath text:[NSString stringFromTCHAR:NumberTools::longToString(NumericUtils::doubleToSortableLong((double)floatValue))] internField:YES]];
    KeywordAnalyzer analyzer = KeywordAnalyzer();
    [predicate materializeWithAnalyzer:&analyzer];
    XCTAssertNotEqualObjects(predicate.query, expected, @"");
}


@end
