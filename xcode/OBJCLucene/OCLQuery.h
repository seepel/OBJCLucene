//
//  OCLQuery.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@class OCLIndexReader;

@interface OCLQuery : NSObject

- (NSArray *)findDocumentsWithIndex:(OCLIndexReader *)inReader;
- (NSArray *)findFieldValuesForName:(NSString *)inName withIndex:(OCLIndexReader *)inReader;

@end
