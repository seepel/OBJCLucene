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

- (NSArray *)executeWithIndex:(OCLIndexReader *)inReader;

@end
