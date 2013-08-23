//
//  NSString+OCL.m
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "NSString+OCL.h"
#import "wchar.h"
#import "StringBuffer.h"

@implementation NSString (OCL)

- (const TCHAR *)toTCHAR
{
    return (const TCHAR*)[self cStringUsingEncoding:NSUTF32LittleEndianStringEncoding];
}

+ (NSString *)stringFromTCHAR:(const TCHAR *)inTCHAR
{
    return [[NSString alloc] initWithBytes:inTCHAR length:wcslen(inTCHAR) * sizeof(TCHAR) encoding:NSUTF32LittleEndianStringEncoding];
}

- (NSString *)escapeForQuery
{
    TCHAR *escaped = QueryParser::escape([self toTCHAR]);
    NSString *string = [NSString stringFromTCHAR:escaped];
    free(escaped);
    
    return string;
}

@end
