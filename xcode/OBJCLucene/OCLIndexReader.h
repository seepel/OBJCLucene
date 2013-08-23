//
//  OCLIndexReader.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@class OCLDocument;

@interface OCLIndexReader : NSObject

- (id)initWithPath:(NSString *)inPath;

- (NSUInteger)numberOfDocuments;
- (OCLDocument *)documentAtIndex:(NSInteger)inIndex;

@end
