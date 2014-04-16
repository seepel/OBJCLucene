//
//  NSPropertyDescription+OCLIncrementalStore.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/13/14.
//
//

#import "NSPropertyDescription+OCLIncrementalStore.h"

NSString * const LuceneIndexed = @"LuceneIndexed";
NSString * const LuceneIgnored = @"LuceneIgnored";

@implementation NSPropertyDescription (OCLIncrementalStore)

- (void)setLuceneIndexed:(BOOL)inLuceneIndexed
{
    NSMutableDictionary *userInfo = [self.userInfo mutableCopy];
    [userInfo setObject:@(inLuceneIndexed) forKey:LuceneIndexed];
    self.userInfo = userInfo;
}

- (BOOL)isLuceneIndexed
{
    return self.isIndexed || [self.userInfo[LuceneIndexed] boolValue];
}

- (void)setLuceneIgnored:(BOOL)inLuceneIgnored
{
    NSMutableDictionary *userInfo = [self.userInfo mutableCopy];
    [userInfo setObject:@(inLuceneIgnored) forKey:LuceneIgnored];
    self.userInfo = userInfo;
}

- (BOOL)isLuceneIgnored
{
    return [self.userInfo[LuceneIgnored] boolValue];
}

@end
