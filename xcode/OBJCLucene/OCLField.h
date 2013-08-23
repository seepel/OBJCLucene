//
//  OCLField.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@interface OCLField : NSObject

@property (readonly) NSString *name;
@property (readonly) NSString *value;
@property (readonly) BOOL tokenized;

@end
