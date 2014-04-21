//
//  OCLStoreRelationshipTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/6/14.
//
//

#import "OCLStoreTests.h"

@interface OCLStoreRelationshipTests : OCLStoreTests

@end

@implementation OCLStoreRelationshipTests

- (void)testNilOneToOne
{
    NSManagedObject *root = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [root setValue:@"rootId" forKey:ObjectIdAttributeName];
    [self.context save:nil];
    NSFetchRequest *rootRequest = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] init];
    localContext.persistentStoreCoordinator = self.coordinator;
    NSManagedObject *fetchedRoot = [localContext executeFetchRequest:rootRequest error:nil][0];
    XCTAssertNil([fetchedRoot valueForKey:OneToOneRelationshipName], @"");
}

- (void)testOneToOne
{
    NSManagedObject *root = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [root setValue:@"rootId" forKey:ObjectIdAttributeName];
    NSManagedObject *oneToOne = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:OneToOneEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [oneToOne setValue:@"oneToOneId" forKey:ObjectIdAttributeName];
    [root setValue:oneToOne forKey:OneToOneRelationshipName];
    [self.context save:nil];
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] init];
    localContext.persistentStoreCoordinator = self.coordinator;

    NSFetchRequest *rootRequest = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    NSManagedObject *fetchedRoot = [localContext executeFetchRequest:rootRequest error:nil][0];
    NSManagedObject *fetchedRootOneToOne = [fetchedRoot valueForKey:OneToOneRelationshipName];
    XCTAssertEqualObjects([fetchedRootOneToOne objectID], oneToOne.objectID, @"fetchedRoot: %@ root: %@", fetchedRoot.objectID, root.objectID);
    XCTAssertEqualObjects([[fetchedRootOneToOne valueForKey:InverseToOneRelationshipName] objectID], root.objectID, @"");
}

- (void)testOneToMany
{
    NSManagedObject *root = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [root setValue:@"rootId" forKey:ObjectIdAttributeName];
    NSMutableSet *oneToManySet = [NSMutableSet set];
    NSMutableSet *expected = [NSMutableSet set];
    for(NSUInteger i = 0; i != 5; i++) {
        NSManagedObject *oneToMany = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:OneToManyEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"oneToManyId%d", i];
        [oneToMany setValue:_id forKey:ObjectIdAttributeName];
        [oneToManySet addObject:oneToMany];
        [expected addObject:[self.store newObjectIDForEntity:oneToMany.entity referenceObject:_id]];
    }
    [root setValue:oneToManySet forKeyPath:OneToManyRelationshipName];
    [self.context save:nil];
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] init];
    localContext.persistentStoreCoordinator = self.coordinator;

    NSFetchRequest *rootRequest = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    NSManagedObject *fetchedRoot = [localContext executeFetchRequest:rootRequest error:nil][0];
    NSSet *result = [fetchedRoot valueForKey:OneToManyRelationshipName] ;//valueForKeyPath:@"objectId"];
    XCTAssertEqualObjects([result valueForKeyPath:@"objectID"], expected, @"");
    [result enumerateObjectsUsingBlock:^(NSManagedObject *object, BOOL *stop) {
        XCTAssertEqualObjects([[object valueForKeyPath:InverseToOneRelationshipName] objectID], root.objectID, @"");
    }];
}

- (void)testManyToMany
{
    NSManagedObject *root = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [root setValue:@"rootId" forKey:ObjectIdAttributeName];
    NSMutableSet *manyToManySet = [NSMutableSet set];
    NSMutableSet *expected = [NSMutableSet set];
    for(NSUInteger i = 0; i != 5; i++) {
        NSManagedObject *manyToMany = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:ManyToManyEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"manyToManyId%d", i];
        [manyToMany setValue:_id forKey:ObjectIdAttributeName];
        [manyToManySet addObject:manyToMany];
        [expected addObject:[self.store newObjectIDForEntity:manyToMany.entity referenceObject:_id]];
    }
    [root setValue:manyToManySet forKeyPath:ManyToManyRelationshipName];
    [self.context save:nil];
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] init];
    localContext.persistentStoreCoordinator = self.coordinator;

    NSFetchRequest *rootRequest = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    NSManagedObject *fetchedRoot = [localContext executeFetchRequest:rootRequest error:nil][0];
    NSSet *result = [fetchedRoot valueForKey:ManyToManyRelationshipName] ;//valueForKeyPath:@"objectId"];
    XCTAssertEqualObjects([result valueForKeyPath:@"objectID"], expected, @"");
    [result enumerateObjectsUsingBlock:^(NSManagedObject *object, BOOL *stop) {
        XCTAssertEqualObjects([[[object valueForKeyPath:InverseToManyRelationshipName] anyObject] objectID], root.objectID, @"");
    }];
}

@end
