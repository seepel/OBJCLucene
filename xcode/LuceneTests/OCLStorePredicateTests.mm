//
//  OCLStorePredicateTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/9/14.
//
//

#import "OCLStorePredicateTests.h"

@implementation OCLStorePredicateTests

- (void)setUp
{
    [super setUp];
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"_id" forKey:ObjectIdAttributeName];
    [object setValue:@(1) forKeyPath:IntegerAttributeName];
    [object setValue:@(1.1f) forKeyPath:FloatAttributeName];
    [object setValue:@"Test" forKeyPath:StringAttributeName];
    [object setValue:[NSDate dateWithTimeIntervalSince1970:1397076225] forKeyPath:DateAttributeName];
    [self.context save:nil];
    self.expectedObjectID = object.objectID;
    [self.context reset];
}

@end