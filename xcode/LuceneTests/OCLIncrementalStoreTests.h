//
//  OCLIncrementalStoreTests.h
//  OBJCLucene
//
//  Created by Sean Lynch on 4/6/14.
//
//

#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>
#import "OCLIncrementalStore.h"

extern NSString *RootEntityName;
extern NSString *OneToOneEntityName;
extern NSString *OneToManyEntityName;
extern NSString *ManyToOneEntityName;
extern NSString *ManyToManyEntityName;

extern NSString *OneToOneRelationshipName;
extern NSString *OneToManyRelationshipName;
extern NSString *ManyToOneRelationshipName;
extern NSString *ManyToManyRelationshipName;

extern NSString *InverseToOneRelationshipName;
extern NSString *InverseToManyRelationshipName;

extern NSString *ObjectIdAttributeName;
extern NSString *IntegerAttributeName;
extern NSString *FloatAttributeName;
extern NSString *StringAttributeName;
extern NSString *DateAttributeName;

@interface OCLIncrementalStoreTests : XCTestCase

@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) OCLIncrementalStore *store;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end

