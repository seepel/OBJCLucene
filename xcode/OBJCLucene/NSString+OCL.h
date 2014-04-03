//
//  NSString+OCL.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (OCL)

- (const wchar_t *)toTCHAR;
- (const wchar_t *)copyToTCHAR;
+ (NSString *)stringFromTCHAR:(const wchar_t *)inTCHAR;
- (NSString *)escapeForQuery;

@end
