//
//  OCLField.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@interface OCLField : NSObject

@property (readonly) NSString *key;
@property (readonly) NSString *value;
@property (readonly) BOOL tokenized;

@end
