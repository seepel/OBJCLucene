//
//  NSPropertyDescription+OCLStore.h
//  OBJCLucene
//
//  Created by Sean Lynch on 4/13/14.
//
//

#import <CoreData/CoreData.h>

extern NSString * const LuceneIndexed;
extern NSString * const LuceneIngnored;

@interface NSPropertyDescription (OCL)

@property (nonatomic, getter = isLuceneIndexed) BOOL luceneIndexed;
@property (nonatomic, getter = isLuceneIgnored) BOOL luceneIgnored;

@end
