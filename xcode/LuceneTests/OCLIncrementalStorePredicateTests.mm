//
//  OCLIncrementalStorePredicateTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/9/14.
//
//

#import "OCLIncrementalStorePredicateTests.h"

@implementation OCLIncrementalStorePredicateTests

- (void)setUp
{
    [super setUp];
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    object._id = @"id";
    [object setValue:@(1) forKeyPath:IntegerAttributeName];
    [object setValue:@(1.1f) forKeyPath:FloatAttributeName];
    [object setValue:@"Test" forKeyPath:StringAttributeName];
    [object setValue:[NSDate dateWithTimeIntervalSince1970:1397076225] forKeyPath:DateAttributeName];
    [self.context save:nil];
    self.expectedObjectID = object.objectID;
    [self.context reset];
}

@end
