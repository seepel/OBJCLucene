//
//  OCLField.m
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "OCLField.h"

@interface OCLField ()

@property (strong) NSString *name;
@property (strong) NSString *value;
@property (assign) BOOL tokenized;

@end

@implementation OCLField

+ (OCLField *)fieldWithName:(NSString *)inName value:(NSString *)inValue tokenized:(BOOL)inTokenized
{
    OCLField *field = [[OCLField alloc] init];
    field.name = inName;
    field.value = inValue;
    field.tokenized = inTokenized;
    
    return  field;
}

@end
