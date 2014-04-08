//
//  OCLIncrementalStoreTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 3/30/14.
//
//

#import "OCLIncrementalStoreTests.h"

NSString *RootEntityName = @"Root";
NSString *OneToOneEntityName = @"OneToOne";
NSString *OneToManyEntityName = @"OneToMany";
NSString *ManyToOneEntityName = @"ManyToOne";
NSString *ManyToManyEntityName = @"ManyToMany";

NSString *OneToOneRelationshipName = @"oneToOne";
NSString *OneToManyRelationshipName = @"oneToMany";
NSString *ManyToOneRelationshipName = @"manyToOne";
NSString *ManyToManyRelationshipName = @"manyToMany";

NSString *InverseToOneRelationshipName = @"root";
NSString *InverseToManyRelationshipName = @"roots";

NSString *IntegerAttributeName = @"integer";
NSString *FloatAttributeName = @"float";
NSString *StringAttributeName = @"string";
NSString *DateAttributeName = @"date";


@implementation OCLIncrementalStoreTests

- (void)setUp
{
    [super setUp];
    self.model = [[NSManagedObjectModel alloc] init];

    NSEntityDescription *rootEntity = [self entityNamed:RootEntityName];
    NSEntityDescription *oneToOneEntity = [self entityNamed:OneToOneEntityName];
    NSEntityDescription *oneToManyEntity = [self entityNamed:OneToManyEntityName];
    NSEntityDescription *manyToOneEntity = [self entityNamed:ManyToOneEntityName];
    NSEntityDescription *manyToManyEntity = [self entityNamed:ManyToManyEntityName];

    // One To One
    NSRelationshipDescription *oneToOneRelationship = [[NSRelationshipDescription alloc] init];
    oneToOneRelationship.name = OneToOneRelationshipName;
    oneToOneRelationship.destinationEntity = oneToOneEntity;
    oneToOneRelationship.maxCount = 1;
    NSRelationshipDescription *inverseOneToOneRelationship = [[NSRelationshipDescription alloc] init];
    inverseOneToOneRelationship.destinationEntity = rootEntity;
    inverseOneToOneRelationship.name = InverseToOneRelationshipName;
    inverseOneToOneRelationship.maxCount = 1;
    oneToOneRelationship.inverseRelationship = inverseOneToOneRelationship;
    inverseOneToOneRelationship.inverseRelationship = oneToOneRelationship;

    // One To Many
    NSRelationshipDescription *oneToManyRelationship = [[NSRelationshipDescription alloc] init];
    oneToManyRelationship.name = OneToManyRelationshipName;
    oneToManyRelationship.destinationEntity = oneToManyEntity;
    NSRelationshipDescription *inverseOneToManyRelationship = [[NSRelationshipDescription alloc] init];
    inverseOneToManyRelationship.name = InverseToOneRelationshipName;
    inverseOneToManyRelationship.destinationEntity = rootEntity;
    inverseOneToManyRelationship.maxCount = 1;
    oneToManyRelationship.inverseRelationship = inverseOneToManyRelationship;
    inverseOneToManyRelationship.inverseRelationship = oneToManyRelationship;

    // Many To One
    NSRelationshipDescription *manyToOneRelationship = [[NSRelationshipDescription alloc] init];
    manyToOneRelationship.name = ManyToOneRelationshipName;
    manyToOneRelationship.destinationEntity = manyToOneEntity;
    manyToOneRelationship.maxCount = 1;
    NSRelationshipDescription *inverseManyToOneRelationship = [[NSRelationshipDescription alloc] init];
    inverseManyToOneRelationship.name = InverseToManyRelationshipName;
    inverseManyToOneRelationship.destinationEntity = rootEntity;
    manyToOneRelationship.inverseRelationship = inverseManyToOneRelationship;
    inverseManyToOneRelationship.inverseRelationship = manyToOneRelationship;

    // Many To Many
    NSRelationshipDescription *manyToManyRelationship = [[NSRelationshipDescription alloc] init];
    manyToManyRelationship.name = ManyToManyRelationshipName;
    manyToManyRelationship.destinationEntity = manyToManyEntity;
    NSRelationshipDescription *inverseManyToManyRelationship = [[NSRelationshipDescription alloc] init];
    inverseManyToManyRelationship.name = InverseToManyRelationshipName;
    inverseManyToManyRelationship.destinationEntity = rootEntity;
    manyToManyRelationship.inverseRelationship = inverseManyToManyRelationship;
    inverseManyToManyRelationship.inverseRelationship = manyToManyRelationship;

    rootEntity.properties = [rootEntity.properties arrayByAddingObjectsFromArray:@[ oneToOneRelationship, oneToManyRelationship, manyToOneRelationship, manyToManyRelationship ]];
    oneToOneEntity.properties = [oneToOneEntity.properties arrayByAddingObjectsFromArray:@[ inverseOneToOneRelationship ]];
    oneToManyEntity.properties = [oneToManyEntity.properties arrayByAddingObjectsFromArray:@[ inverseOneToManyRelationship ]];
    manyToOneEntity.properties = [manyToOneEntity.properties arrayByAddingObjectsFromArray:@[ inverseManyToOneRelationship ]];
    manyToManyEntity.properties = [manyToManyEntity.properties arrayByAddingObjectsFromArray:@[ inverseManyToManyRelationship ]];


    self.model.entities = @[ rootEntity, oneToOneEntity, oneToManyEntity, manyToOneEntity, manyToManyEntity ];
    [OCLIncrementalStore initialize];
    self.coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    NSURL *URL = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"store"]];
    [[NSFileManager defaultManager] removeItemAtPath:URL.path error:nil];
    NSError *error = nil;
    self.store = (OCLIncrementalStore *)[self.coordinator addPersistentStoreWithType:OCLIncrementalStoreType configuration:nil URL:URL options:nil error:&error];
    if(self.store == nil) {
        NSLog(@"Error adding store: %@, %@", error, error.userInfo);
    }
    self.context = [[NSManagedObjectContext alloc] init];
    self.context.persistentStoreCoordinator = self.coordinator;
}

- (NSEntityDescription *)entityNamed:(NSString *)entityName
{
    NSEntityDescription *rootEntity = [[NSEntityDescription alloc] init];
    rootEntity.managedObjectClassName = NSStringFromClass([OCLManagedObject class]);
    rootEntity.name = entityName;
    
    NSAttributeDescription *integerAttribute = [[NSAttributeDescription alloc] init];
    integerAttribute.indexed = YES;
    integerAttribute.name = IntegerAttributeName;
    integerAttribute.attributeType = NSInteger64AttributeType;
    
    NSAttributeDescription *floatAttribute = [[NSAttributeDescription alloc] init];
    floatAttribute.name = FloatAttributeName;
    floatAttribute.attributeType = NSFloatAttributeType;
    floatAttribute.indexed = YES;
    
    NSAttributeDescription *stringAttribute = [[NSAttributeDescription alloc] init];
    stringAttribute.name = StringAttributeName;
    stringAttribute.attributeType = NSStringAttributeType;
    stringAttribute.indexed = YES;
    
    NSAttributeDescription *dateAttribute = [[NSAttributeDescription alloc] init];
    dateAttribute.name = DateAttributeName;
    dateAttribute.attributeType = NSDateAttributeType;
    dateAttribute.indexed = YES;
    
    rootEntity.properties = @[ integerAttribute, floatAttribute, stringAttribute, dateAttribute ];
    
    return rootEntity;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInitialization
{
    XCTAssertEqual(1, self.coordinator.persistentStores.count, @"");
}

- (void)testSingleCountRequest
{
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    BOOL success = [self.context save:nil];
    XCTAssertTrue(success, @"");
    XCTAssertTrue(!object.objectID.isTemporaryID, @"");
    XCTAssertEqualObjects(object.objectID, [self.store newObjectIDForEntity:object.entity referenceObject:@"id"], @"");
    XCTAssertEqual([self.context countForFetchRequest:[[NSFetchRequest alloc] initWithEntityName:RootEntityName]  error:nil], 1, @"");
}

- (void)testObjectIdRequest
{
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:@(1) forKeyPath:@"integer"];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.resultType = NSManagedObjectIDResultType;
    XCTAssertEqualObjects([self.context executeFetchRequest:request error:nil], @[ object.objectID ], @"");
}

- (void)testObjectRequest
{
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:@(1) forKeyPath:@"integer"];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    NSManagedObject *result = [self.context executeFetchRequest:request error:nil][0];
    XCTAssertEqualObjects(result, object, @"");
}

- (void)testDictionaryRequest
{
    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:@(1) forKeyPath:@"integer"];
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[ object.entity.propertiesByName[@"integer"] ];
    NSManagedObject *result = [self.context executeFetchRequest:request error:nil][0];
    NSDictionary *expected = @{ @"_id": @"id", @"integer": @(1) };
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testMultipleAdd
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context];
    for(int i=0; i!= 100; i++) {
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"id%02d", i];
        [object setValue:_id forKeyPath:@"_id"];
        [object setValue:@(1) forKeyPath:@"integer"];
        [expected addObject:[self.store newObjectIDForEntity:entity referenceObject:_id]];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.resultType = NSManagedObjectIDResultType;
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testSortDescriptor
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context];
    for(int i=0; i!= 100; i++) {
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"id%02d", i];
        [object setValue:_id forKeyPath:@"_id"];
        [object setValue:@(99-i) forKeyPath:@"integer"];
        [expected insertObject:object atIndex:0];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"integer" ascending:YES] ];
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testReverseSortDescriptor
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context];
    for(int i=0; i!= 100; i++) {
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"%02d", i];
        [object setValue:_id forKeyPath:@"_id"];
        [object setValue:@(99-i) forKeyPath:@"integer"];
        [expected addObject:object];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"integer" ascending:NO] ];
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testDoubleInsert
{
    NSMutableArray *expected = [NSMutableArray array];
    NSEntityDescription *entity = [NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context];
    for(int i=0; i!= 5; i++) {
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"%02d", i];
        [object setValue:_id forKeyPath:@"_id"];
        [object setValue:@(99-i) forKeyPath:@"integer"];
    }
    [self.context save:nil];
    for(int i=0; i!= 5; i++) {
        OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
        NSString *_id = [NSString stringWithFormat:@"%02d", i];
        [object setValue:_id forKeyPath:@"_id"];
        [object setValue:@(i) forKeyPath:@"integer"];
        [expected addObject:object];
    }
    [self.context save:nil];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:RootEntityName];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"integer" ascending:YES] ];
    NSArray *result = [self.context executeFetchRequest:request error:nil];
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testDataRetrieval
{
    NSNumber *integerValue =  @(1);
    NSNumber *floatValue = @(1.1);
    NSString *stringValue = @"test";

    OCLManagedObject *object = [[OCLManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:RootEntityName inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    [object setValue:@"id" forKeyPath:@"_id"];
    [object setValue:integerValue forKeyPath:@"integer"];
    [object setValue:floatValue forKeyPath:@"float"];
    [object setValue:stringValue forKeyPath:@"string"];
    [self.context save:nil];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = self.coordinator;
    OCLManagedObject *result = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:RootEntityName] error:nil][0];
    XCTAssertEqualObjects([result valueForKey:@"integer"], integerValue, @"");
    XCTAssert(fabs(([[result valueForKey:@"float"] floatValue] - [floatValue floatValue])) < 0.001, @"actual: %@ expected: %@", [result valueForKey:@"float"], floatValue);
    XCTAssertEqualObjects([result valueForKey:@"string"], stringValue, @"");
}


@end
