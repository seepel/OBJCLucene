//
//  NSManagedObject+OCLIncrementalStore.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/15/14.
//
//

#import "NSManagedObject+OCLIncrementalStore.h"
#import "NSEntityDescription+OCLIncrementalStore.h"

@implementation NSManagedObject (OCLIncrementalStore)

- (id)oclId;
{
    return [self valueForKey:self.entity.attributeNameForObjectId];
}

@end
