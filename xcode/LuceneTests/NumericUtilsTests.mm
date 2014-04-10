//
//  NumericUtilsTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/9/14.
//
//

#import <XCTest/XCTest.h>
#import "NumberTools.h"
#import "NumericUtils.h"

using namespace ocl;

@interface NumericUtilsTests : XCTestCase

@end

@implementation NumericUtilsTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInAndOut
{
    NSNumber *inNumber = @(1.1);
    double inDouble = [inNumber doubleValue];
    int64_t inLong = NumericUtils::doubleToSortableLong(inDouble);
    TCHAR *savedString = NumberTools::longToString(inLong);
    int64_t outLong = NumberTools::stringToLong(savedString);
    double outDouble = NumericUtils::sortableLongToDouble(outLong);
    NSNumber *outNumber = [NSNumber numberWithDouble:outDouble];
    XCTAssertEqual([outNumber doubleValue], [inNumber doubleValue], @"");
}

@end
