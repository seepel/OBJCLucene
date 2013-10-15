//
//  OCLTermPrivate.h
//  OBJCLucene
//
//  Created by Sean Lynch on 9/20/13.
//
//

#import <Foundation/Foundation.h>
#import "OCLTerm.h"


@interface OCLTerm (Private)

- (void)setCPPTerm:(Term *)term;
- (Term *)cppTerm;

@end