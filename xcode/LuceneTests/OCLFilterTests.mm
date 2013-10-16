//
//  OCLFilterTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/16/13.
//
//

#import <XCTest/XCTest.h>
#import "OBJCLucene.h"
#import "OCLFilterPrivate.h"
#import "NSString+OCL.h"
#import "TermQuery.h"
#import "QueryFilter.h"
#import "CachingWrapperFilter.h"

@interface OCLFilterTests : XCTestCase

@end

@implementation OCLFilterTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testQueryFilter
{
    OCLTermQuery *oclTermQuery = [[OCLTermQuery alloc] initWithTerm:[[OCLTerm alloc] initWithField:@"f" text:@"t" internField:YES]];
    OCLFilter *oclFilter = [[OCLFilter alloc] initWithQuery:oclTermQuery];
    
    Term *term = _CLNEW Term([@"f" toTCHAR], [@"t" toTCHAR], true);
    TermQuery *termQuery = _CLNEW TermQuery(term);
    QueryFilter *filter = _CLNEW QueryFilter(termQuery);
    XCTAssertEqualObjects([NSString stringFromTCHAR:filter->toString()], [NSString stringFromTCHAR:[oclFilter cppFilter]->toString()], @"");
}

- (void)testCachedQueryFilter
{
    OCLTermQuery *oclTermQuery = [[OCLTermQuery alloc] initWithTerm:[[OCLTerm alloc] initWithField:@"f" text:@"t" internField:YES]];
    OCLFilter *oclFilter = [[OCLFilter alloc] initWithQuery:oclTermQuery cache:YES];
    
    Term *term = _CLNEW Term([@"f" toTCHAR], [@"t" toTCHAR], true);
    TermQuery *termQuery = _CLNEW TermQuery(term);
    QueryFilter *queryFilter = _CLNEW QueryFilter(termQuery);
    CachingWrapperFilter *filter =_CLNEW CachingWrapperFilter(queryFilter);
    XCTAssertEqualObjects([NSString stringFromTCHAR:filter->toString()], [NSString stringFromTCHAR:[oclFilter cppFilter]->toString()], @"");
}

- (void)testPrefixFilter
{
    OCLPrefixFilter *oclFilter = [[OCLPrefixFilter alloc] initWithTerm:[[OCLTerm alloc] initWithField:@"f" text:@"t" internField:YES]];
    
    Term *term = _CLNEW Term([@"f" toTCHAR], [@"t" toTCHAR], true);
    PrefixFilter *filter = _CLNEW PrefixFilter(term);
    XCTAssertEqualObjects([NSString stringFromTCHAR:filter->toString()], [NSString stringFromTCHAR:[oclFilter cppFilter]->toString()], @"");
}

- (void)testCachingPrefixFilter
{
    OCLPrefixFilter *oclFilter = [[OCLPrefixFilter alloc] initWithTerm:[[OCLTerm alloc] initWithField:@"f" text:@"t" internField:YES] cache:YES];
    
    Term *term = _CLNEW Term([@"f" toTCHAR], [@"t" toTCHAR], true);
    PrefixFilter *prefixFilter = _CLNEW PrefixFilter(term);
    CachingWrapperFilter *filter = _CLNEW CachingWrapperFilter(prefixFilter);
    XCTAssertEqualObjects([NSString stringFromTCHAR:filter->toString()], [NSString stringFromTCHAR:[oclFilter cppFilter]->toString()], @"");
}

- (void)testWildcardFilter
{
    OCLWildcardFilter *oclFilter = [[OCLWildcardFilter alloc] initWithTerm:[[OCLTerm alloc] initWithField:@"f" text:@"t" internField:YES]];
    
    Term *term = _CLNEW Term([@"f" toTCHAR], [@"t" toTCHAR], true);
    WildcardFilter *filter = _CLNEW WildcardFilter(term);
    XCTAssertEqualObjects([NSString stringFromTCHAR:filter->toString()], [NSString stringFromTCHAR:[oclFilter cppFilter]->toString()], @"");
}

- (void)testCachingWildcardFilter
{
    OCLWildcardFilter *oclFilter = [[OCLWildcardFilter alloc] initWithTerm:[[OCLTerm alloc] initWithField:@"f" text:@"t" internField:YES] cache:YES];
    
    Term *term = _CLNEW Term([@"f" toTCHAR], [@"t" toTCHAR], true);
    WildcardFilter *wildCardFilter = _CLNEW WildcardFilter(term);
    CachingWrapperFilter *filter = _CLNEW CachingWrapperFilter(wildCardFilter);
    XCTAssertEqualObjects([NSString stringFromTCHAR:filter->toString()], [NSString stringFromTCHAR:[oclFilter cppFilter]->toString()], @"");
}


@end
