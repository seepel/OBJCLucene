//
//  OCLField.m
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "OCLField.h"
#import "OCLFieldPrivate.h"

#import "NSString+OCL.h"

@interface OCLField () {
    Field *_cppField;
}

@property (strong, readwrite) NSString *key;

@end

@implementation OCLField

+ (OCLField *)fieldWithKey:(NSString *)inKey value:(NSString *)inValue tokenized:(BOOL)inTokenized
{
    OCLFieldConfig config = OCLFieldConfigStoreYES;
    if(inTokenized) {
        config = config|OCLFieldConfigIndexTokenized;
    } else {
        config = config|OCLFieldConfigIndexUntokenized;
    }
    return [[self alloc] initWithKey:inKey value:inValue config:config duplicateValue:YES];
}

- (instancetype)initWithKey:(NSString *)key value:(NSString *)value config:(OCLFieldConfig)config duplicateValue:(BOOL)duplicateValue
{
    if((self = [super init])) {
        Field *field = _CLNEW Field([key toTCHAR], [value toTCHAR], config, duplicateValue);
        [self setCPPField:field];
    }
    return self;
}

- (void)setCPPField:(lucene::document::Field *)inField
{
    if(_cppField != NULL) {
        _CLVDELETE(_cppField);
    }
    _cppField = inField;
}

- (Field *)cppField
{
    return _cppField;
}

- (void)dealloc
{
    if(_cppField != NULL) {
        _CLVDELETE(_cppField);
    }
}

- (BOOL)isTokenized
{
    if(_cppField == NULL) {
        return NO;
    }
    return _cppField->isTokenized();
}

- (BOOL)isStored
{
    if(_cppField == NULL) {
        return NO;
    }
    return _cppField->isStored();
}

- (BOOL)isCompressed
{
    if(_cppField == NULL) {
        return NO;
    }
    return _cppField->isCompressed();
}

- (BOOL)isTermVectorStored
{
    if(_cppField == NULL) {
        return NO;
    }
    return _cppField->isTermVectorStored();
}

- (BOOL)isStoreOffsetWithTermVector
{
    if(_cppField == NULL) {
        return NO;
    }
    return _cppField->isStoreOffsetWithTermVector();
}

- (BOOL)isStorePositionWithTermVector
{
    if(_cppField == NULL) {
        return NO;
    }
    return _cppField->isStorePositionWithTermVector();
}

- (BOOL)isBinary
{
    if(_cppField == NULL) {
        return NO;
    }
    return _cppField->isBinary();
}

- (BOOL)isLazy
{
    if(_cppField == NULL) {
        return NO;
    }
    return _cppField->isLazy();
}

@end
