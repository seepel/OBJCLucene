//
//  NSManagedObject+OCLStore.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/15/14.
//
//

#import "NSManagedObject+OCL.h"
#import "NSEntityDescription+OCL.h"

@implementation NSManagedObject (OCL)

- (id)oclId;
{
    return [self valueForKey:self.entity.attributeNameForObjectId];
}

@end
