//
//  OCLDocument.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@class OCLField;

@interface OCLDocument : NSObject

- (void)addFieldForName:(NSString *)inName value:(NSString *)inValue tokenized:(BOOL)inTokenized;
- (OCLField *)fieldForName:(NSString *)inKey;
- (void)removeFieldForName:(NSString *)inKey;

- (void)clear;

@end
