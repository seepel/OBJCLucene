//
//  OCLFilter.h
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import <Foundation/Foundation.h>

@class OCLQuery;

@interface OCLFilter : NSObject

@property (nonatomic, readonly) OCLQuery *query;

- (id)initWithQuery:(OCLQuery *)query;
- (id)initWithQuery:(OCLQuery *)query cache:(BOOL)cache;

@end
