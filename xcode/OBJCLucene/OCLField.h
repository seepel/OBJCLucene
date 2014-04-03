//
//  OCLField.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OCLFieldStore) {
    OCLFieldStoreYES = 1,
    OCLFieldStoreNO = 2
};

typedef NS_ENUM(NSInteger, OCLFieldIndex) {
    OCLFieldIndexNO = 16,
    OCLFieldIndexTokenized = 32,
    OCLFieldIndexUntokenized = 64,
    OCLFieldIndexNoNorms = 128
};

typedef NS_ENUM(NSInteger, OCLFieldTermVector) {
    OCLFieldTermVectorNO = 256,
    OCLFieldTermVectorYES = 512,
    OCLFieldTermVectorWithPositions = OCLFieldTermVectorYES | 1024,
    OCLFieldTermVectorWithOffsets = OCLFieldTermVectorYES | 2048,
    OCLFieldTermVectorWithPositionsOffsets = OCLFieldTermVectorWithPositions | OCLFieldTermVectorWithOffsets
};

typedef NS_OPTIONS(NSInteger, OCLFieldConfig) {
    OCLFieldConfigStoreYES = OCLFieldStoreYES,
    OCLFieldConfigStoreNO = OCLFieldStoreNO,
    OCLFieldConfigIndexNO = OCLFieldIndexNO,
    OCLFieldConfigIndexTokenized = OCLFieldIndexTokenized,
    OCLFieldConfigIndexUntokenized = OCLFieldIndexUntokenized,
    OCLFieldConfigIndexNoNorms = OCLFieldIndexNoNorms,
    OCLFieldConfigTermVectorNO = OCLFieldTermVectorNO,
    OCLFieldConfigTermVectorYES = OCLFieldTermVectorYES,
    OCLFieldConfigTermVectorWithPositions = OCLFieldTermVectorWithPositions,
    OCLFieldConfigTermVectorWithOffsets = OCLFieldTermVectorWithOffsets,
    OCLFieldConfigTermVectorWithPositionsOffsets = OCLFieldTermVectorWithPositionsOffsets
};

@interface OCLField : NSObject

- (instancetype)initWithKey:(NSString *)key value:(NSString *)value config:(OCLFieldConfig)config duplicateValue:(BOOL)duplicateValue;

@property (readonly) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic) float_t boost;

@property (readonly, getter = isTokenized) BOOL tokenized;
@property (readonly, getter = isStored) BOOL stored;
@property (readonly, getter = isCompressed) BOOL compressed;
@property (readonly, getter = isTermVectorStored) BOOL termVectorStored;
@property (readonly, getter = isStoreOffsetWithTermVector) BOOL storeOffsetWithTermVector;
@property (readonly, getter = isStorePositionWithTermVector) BOOL storePositionWithTermVector;

@property (readonly, getter = isBinary) BOOL binary;
@property (readonly, getter = isLazy) BOOL lazy;

@end
