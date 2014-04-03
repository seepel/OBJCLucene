//
//  OCLFieldPrivate.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "OCLField.h"

@interface OCLField (Private)

- (void)setCPPField:(Field *)inField;
- (Field *)cppField;

+ (OCLField *)fieldWithKey:(NSString *)inKey value:(NSString *)inValue tokenized:(BOOL)inTokenized;

@end
