//
//  OCLFilterPrivate.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLFilter.h"
#import "Filter.h"

@interface OCLFilter (Private)

- (void)setCPPFilter:(Filter *)filter;
- (Filter *)cppFilter;

@end