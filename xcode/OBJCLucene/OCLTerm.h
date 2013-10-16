//
//  OCLTerm.h
//  OBJCLucene
//
//  Created by Sean Lynch on 9/20/13.
//
//

#import <Foundation/Foundation.h>

/**
 @class OCLTerm
 @abstract A Term represents a word from text. This is the unit of search. It is composed of two elements, the text of the word, as a string, and the name of the field that the text occurred in, an interned string. Note that terms may represent more than words from text fields, but also things like dates, email addresses, urls, etc.
 @author Sean Lynch
 @version 1.0
*/
@interface OCLTerm : NSObject

@property (nonatomic, strong, readonly) NSString *field;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic) BOOL internField;

/**
 @method initWithField:
 @abstract Returns an initialized OCLTerm with the given field and text
 @param field An NSString with the name of the field to be matched by the term
 @param text An NSString with the text that should be matched
 @param internField 
 @result An initialized OCLTerm with the given field and text
 */
- (id)initWithField:(NSString *)field text:(NSString *)text internField:(BOOL)internField;

@end
