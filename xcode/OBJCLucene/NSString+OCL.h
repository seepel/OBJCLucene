//
//  NSString+OCL.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (OCL)

- (const TCHAR *)toTCHAR;
- (const TCHAR *)copyToTCHAR;
+ (NSString *)stringFromTCHAR:(const TCHAR *)inTCHAR;
- (NSString *)escapeForQuery;

@end
