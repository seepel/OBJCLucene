//
//  OCLStoreTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 3/30/14.
//
//

#import "OCLStoreTests.h"
#import "NSEntityDescription+OCLStore.h"

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

NSString *ObjectIdAttributeName = @"_id";
NSString *IntegerAttributeName = @"integer";
NSString *FloatAttributeName = @"float";
NSString *StringAttributeName = @"string";
NSString *DateAttributeName = @"date";


@interface OCLStoreTests ()

@property (nonatomic, strong) NSURL *storeURL;

@end

@implementation OCLStoreTests

- (void)setUp
{
    [super setUp];
    self.model = [[NSManagedObjectModel alloc] init];

    NSEntityDescription *rootEntity = [self entityNamed:RootEntityName];
    rootEntity.userInfo = @{ OCLAttributeForObjectId: ObjectIdAttributeName };
    NSEntityDescription *oneToOneEntity = [self entityNamed:OneToOneEntityName];
    oneToOneEntity.userInfo = @{ OCLAttributeForObjectId: ObjectIdAttributeName };
    NSEntityDescription *oneToManyEntity = [self entityNamed:OneToManyEntityName];
    oneToManyEntity.userInfo = @{ OCLAttributeForObjectId: ObjectIdAttributeName };
    NSEntityDescription *manyToOneEntity = [self entityNamed:ManyToOneEntityName];
    manyToOneEntity.userInfo = @{ OCLAttributeForObjectId: ObjectIdAttributeName };
    NSEntityDescription *manyToManyEntity = [self entityNamed:ManyToManyEntityName];
    manyToManyEntity.userInfo = @{ OCLAttributeForObjectId: ObjectIdAttributeName };

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
    [OCLStore initialize];
    self.coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    self.storeURL = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]]];
    [[NSFileManager defaultManager] removeItemAtPath:self.storeURL.path error:nil];
    NSError *error = nil;
    self.store = (OCLStore *)[self.coordinator addPersistentStoreWithType:OCLStoreType configuration:nil URL:self.storeURL options:nil error:&error];
    if(self.store == nil) {
        NSLog(@"Error adding store: %@, %@", error, error.userInfo);
    }
    self.context = [[NSManagedObjectContext alloc] init];
    self.context.persistentStoreCoordinator = self.coordinator;
}

- (void)tearDown
{
    [super tearDown];
    [[NSFileManager defaultManager] removeItemAtPath:self.storeURL.path error:nil];
}

- (NSEntityDescription *)entityNamed:(NSString *)entityName
{
    NSEntityDescription *rootEntity = [[NSEntityDescription alloc] init];
    rootEntity.managedObjectClassName = NSStringFromClass([NSManagedObject class]);
    rootEntity.name = entityName;

    NSAttributeDescription *objectIDAttribute = [[NSAttributeDescription alloc] init];
    objectIDAttribute.indexed = YES;
    objectIDAttribute.name = ObjectIdAttributeName;
    objectIDAttribute.attributeType = NSStringAttributeType;
    
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
    
    rootEntity.properties = @[ objectIDAttribute, integerAttribute, floatAttribute, stringAttribute, dateAttribute ];
    
    return rootEntity;
}


@end
