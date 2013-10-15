//
//  OCLTerm.h
//  OBJCLucene
//
//  Created by Sean Lynch on 9/20/13.
//
//

#import <Foundation/Foundation.h>

@interface OCLTerm : NSObject

@property (nonatomic, strong, readonly) NSString *field;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic) BOOL internField;

- (id)initWithField:(NSString *)field text:(NSString *)text internField:(BOOL)internField;

@end
