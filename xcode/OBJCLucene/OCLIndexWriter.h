//
//  OCLIndexWriter.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <Foundation/Foundation.h>

@class OCLDocument;

@interface OCLIndexWriter : NSObject

- (id)initWithPath:(NSString *)inPath overwrite:(BOOL)inOverwrite;

@property (nonatomic, assign) int32_t   maxFieldLength;
@property (nonatomic, assign) BOOL      useCompoundFile;

@property (readonly) NSString *path;

- (void)addDocument:(OCLDocument *)inDocument;
- (void)removeDocumentsWithFieldName:(NSString *)inFieldName matchingValue:(NSString *)inValue;
- (void)replaceDocumentsWithFieldName:(NSString *)inFieldName matchingValue:(NSString *)inValue withDocument:(OCLDocument *)inDocument;


- (void)flush;
- (void)optimize:(BOOL)inWaitUntilDone;

@end
