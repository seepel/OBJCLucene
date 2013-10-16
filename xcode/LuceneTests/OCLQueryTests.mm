//
//  OCLQueryTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import <XCTest/XCTest.h>
#import "OBJCLucene.h"
#import "OCLQueryPrivate.h"
#import "TermQuery.h"
#import "NSString+OCL.h"
#import "MultiPhraseQuery.h"

@interface OCLQueryTests : XCTestCase

@end

@implementation OCLQueryTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testTermQuery
{
    OCLTermQuery *oclTermQuery = [[OCLTermQuery alloc] initWithTerm:[[OCLTerm alloc] initWithField:@"f" text:@"t" internField:YES]];
    Term *term = _CLNEW Term([@"f" toTCHAR], [@"t" toTCHAR], true);
    TermQuery *termQuery = _CLNEW TermQuery(term);
    XCTAssertTrue(termQuery->equals([oclTermQuery cppQuery]) , @"");
}

- (void)testBooleanQuery
{
    OCLTermQuery *oclTermQuery = [[OCLTermQuery alloc] initWithTerm:[[OCLTerm alloc] initWithField:@"f" text:@"t" internField:YES]];
    Term *term = _CLNEW Term([@"f" toTCHAR], [@"t" toTCHAR], true);
    TermQuery *termQuery = _CLNEW TermQuery(term);
    
    OCLBooleanClause *oclBooleanClause = [[OCLBooleanClause alloc] initWithQuery:oclTermQuery occur:OCLBooleanClauseShouldOccur];
    OCLBooleanQuery *oclBooleanQuery = [[OCLBooleanQuery alloc] initWithClauses:@[oclBooleanClause]];
    
    BooleanQuery *booleanQuery = _CLNEW BooleanQuery();
    booleanQuery->add(termQuery, true, BooleanClause::Occur::SHOULD);
    XCTAssertTrue(booleanQuery->equals([oclBooleanQuery cppQuery]), @"");
}

- (void)testFuzzyQuery
{
    OCLFuzzyQuery *oclFuzzyQuery = [[OCLFuzzyQuery alloc] initWithTerm:[[OCLTerm alloc] initWithField:@"f" text:@"t" internField:YES] minimumSimilarity:0.4 prefixLength:2];
    Term *term = _CLNEW Term([@"f" toTCHAR], [@"t" toTCHAR], true);
    
    FuzzyQuery *fuzzyQuery = _CLNEW FuzzyQuery(term, 0.4, 2);
    XCTAssertTrue(fuzzyQuery->equals([oclFuzzyQuery cppQuery]), @"");
    
}

- (void)testMultiPhraseQuery
{
    OCLMultiPhraseQuery *oclMultiPhraseQuery = [[OCLMultiPhraseQuery alloc] initWithTerms:@[ [[OCLTerm alloc] initWithField:@"f" text:@"t1" internField:YES],
                                                                                             [[OCLTerm alloc] initWithField:@"f" text:@"t2" internField:YES] ]
                                                                                     slop:2];
    Term *term1 = _CLNEW Term([@"f" toTCHAR], [@"t1" toTCHAR], true);
    Term *term2 = _CLNEW Term([@"f" toTCHAR], [@"t2" toTCHAR], true);
    MultiPhraseQuery *multiPhraseQuery = _CLNEW MultiPhraseQuery();
    multiPhraseQuery->add(term1);
    multiPhraseQuery->add(term2);
    multiPhraseQuery->setSlop(2);
    XCTAssertTrue(multiPhraseQuery->equals([oclMultiPhraseQuery cppQuery]), @"");
}

- (void)testPhraseQuery
{
    OCLPhraseQuery *oclPhraseQuery = [[OCLPhraseQuery alloc] initWithTerms:@[ [[OCLTerm alloc] initWithField:@"f" text:@"t1" internField:YES],
                                                                                             [[OCLTerm alloc] initWithField:@"f" text:@"t2" internField:YES] ]
                                                                                     slop:2];
    Term *term1 = _CLNEW Term([@"f" toTCHAR], [@"t1" toTCHAR], true);
    Term *term2 = _CLNEW Term([@"f" toTCHAR], [@"t2" toTCHAR], true);
    PhraseQuery *multiPhraseQuery = _CLNEW PhraseQuery();
    multiPhraseQuery->add(term1);
    multiPhraseQuery->add(term2);
    multiPhraseQuery->setSlop(2);
    XCTAssertTrue(multiPhraseQuery->equals([oclPhraseQuery cppQuery]), @"");
}

- (void)testPrefixQuery
{
    OCLPrefixQuery * oclPrefixQuery = [[OCLPrefixQuery alloc] initWithTerm:[[OCLTerm alloc] initWithField:@"f" text:@"t" internField:YES]];
    
    Term *term = _CLNEW Term([@"f" toTCHAR], [@"t" toTCHAR], true);
    PrefixQuery *prefixQuery = _CLNEW PrefixQuery(term);
    
    XCTAssertTrue(prefixQuery->equals([oclPrefixQuery cppQuery]), @"");
}

- (void)testWildcardQuery
{
    OCLWildcardQuery * oclWildcardQuery = [[OCLWildcardQuery alloc] initWithTerm:[[OCLTerm alloc] initWithField:@"f" text:@"t" internField:YES]];
    
    Term *term = _CLNEW Term([@"f" toTCHAR], [@"t" toTCHAR], true);
    WildcardQuery *prefixQuery = _CLNEW WildcardQuery(term);
    
    XCTAssertTrue(prefixQuery->equals([oclWildcardQuery cppQuery]), @"");
}

@end
