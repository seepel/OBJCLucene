//
//  OCLDocumentTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/16/13.
//
//

#import <XCTest/XCTest.h>
#import "OBJCLucene.h"
#import "OCLDocumentPrivate.h"

@interface OCLDocumentTests : XCTestCase

@end

@implementation OCLDocumentTests

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

- (void)testAddFieldValue
{
    OCLDocument *document = [[OCLDocument alloc] init];
    [document addFieldForKey:@"f" value:@"t" tokenized:NO];
    OCLField *field = [document fieldForKey:@"f"];
    XCTAssertEqualObjects(field.value, @"t", @"");
}

- (void)testAddTokenizedFieldValue
{
    OCLDocument *document = [[OCLDocument alloc] init];
    [document addFieldForKey:@"f" value:@"t1 t2" tokenized:YES];
    OCLField *field = [document fieldForKey:@"f"];
    XCTAssertEqualObjects(field.value, @"t1 t2", @"");
}

- (void)testRemoveFieldValue
{
    OCLDocument *document = [[OCLDocument alloc] init];
    [document addFieldForKey:@"f" value:@"t" tokenized:NO];
    [document removeFieldForKey:@"f"];
    OCLField *field = [document fieldForKey:@"f"];
    XCTAssertNil(field, @"");
}

@end
