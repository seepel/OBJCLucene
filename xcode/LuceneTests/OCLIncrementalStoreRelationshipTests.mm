//
//  OCLIncrementalStoreRelationshipTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/6/14.
//
//

#import "OCLIncrementalStoreTests.h"

@interface OCLIncrementalStoreRelationshipTests : OCLIncrementalStoreTests

@end

@implementation OCLIncrementalStoreRelationshipTests

- (void)testNilOneToOne
{
    OCLManagedObject *root = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    root._id = @"rootId";
    [self.context save:nil];
    NSFetchRequest *rootRequest = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] init];
    localContext.persistentStoreCoordinator = self.coordinator;
    OCLManagedObject *fetchedRoot = [localContext executeFetchRequest:rootRequest error:nil][0];
    XCTAssertNil([fetchedRoot valueForKey:OneToOneRelationshipName], @"");
}

- (void)testOneToOne
{
    OCLManagedObject *root = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    root._id = @"rootId";
    OCLManagedObject *oneToOne = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:OneToOneEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    oneToOne._id = @"oneToOneId";
    [root setValue:oneToOne forKey:OneToOneRelationshipName];
    [self.context save:nil];
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] init];
    localContext.persistentStoreCoordinator = self.coordinator;

    NSFetchRequest *rootRequest = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    OCLManagedObject *fetchedRoot = [localContext executeFetchRequest:rootRequest error:nil][0];
    OCLManagedObject *fetchedRootOneToOne = [fetchedRoot valueForKey:OneToOneRelationshipName];
    XCTAssertEqualObjects([fetchedRootOneToOne objectID], oneToOne.objectID, @"fetchedRoot: %@ root: %@", fetchedRoot.objectID, root.objectID);
    XCTAssertEqualObjects([[fetchedRootOneToOne valueForKey:InverseToOneRelationshipName] objectID], root.objectID, @"");
}

- (void)testOneToMany
{
    OCLManagedObject *root = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    root._id = @"rootId";
    NSMutableSet *oneToManySet = [NSMutableSet set];
    NSMutableSet *expected = [NSMutableSet set];
    for(NSUInteger i = 0; i != 5; i++) {
        OCLManagedObject *oneToMany = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:OneToManyEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"oneToManyId%d", i];
        oneToMany._id = _id;
        [oneToManySet addObject:oneToMany];
        [expected addObject:[self.store newObjectIDForEntity:oneToMany.entity referenceObject:_id]];
    }
    [root setValue:oneToManySet forKeyPath:OneToManyRelationshipName];
    [self.context save:nil];
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] init];
    localContext.persistentStoreCoordinator = self.coordinator;

    NSFetchRequest *rootRequest = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    OCLManagedObject *fetchedRoot = [localContext executeFetchRequest:rootRequest error:nil][0];
    NSSet *result = [fetchedRoot valueForKey:OneToManyRelationshipName] ;//valueForKeyPath:@"objectId"];
    XCTAssertEqualObjects([result valueForKeyPath:@"objectID"], expected, @"");
    [result enumerateObjectsUsingBlock:^(OCLManagedObject *object, BOOL *stop) {
        XCTAssertEqualObjects([[object valueForKeyPath:InverseToOneRelationshipName] objectID], root.objectID, @"");
    }];
}

- (void)testManyToMany
{
    OCLManagedObject *root = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    root._id = @"rootId";
    NSMutableSet *manyToManySet = [NSMutableSet set];
    NSMutableSet *expected = [NSMutableSet set];
    for(NSUInteger i = 0; i != 5; i++) {
        OCLManagedObject *manyToMany = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:ManyToManyEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"manyToManyId%d", i];
        manyToMany._id = _id;
        [manyToManySet addObject:manyToMany];
        [expected addObject:[self.store newObjectIDForEntity:manyToMany.entity referenceObject:_id]];
    }
    [root setValue:manyToManySet forKeyPath:ManyToManyRelationshipName];
    [self.context save:nil];
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] init];
    localContext.persistentStoreCoordinator = self.coordinator;

    NSFetchRequest *rootRequest = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    OCLManagedObject *fetchedRoot = [localContext executeFetchRequest:rootRequest error:nil][0];
    NSSet *result = [fetchedRoot valueForKey:ManyToManyRelationshipName] ;//valueForKeyPath:@"objectId"];
    XCTAssertEqualObjects([result valueForKeyPath:@"objectID"], expected, @"");
    [result enumerateObjectsUsingBlock:^(OCLManagedObject *object, BOOL *stop) {
        XCTAssertEqualObjects([[[object valueForKeyPath:InverseToManyRelationshipName] anyObject] objectID], root.objectID, @"");
    }];
}

@end
