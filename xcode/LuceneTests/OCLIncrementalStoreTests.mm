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


@end
