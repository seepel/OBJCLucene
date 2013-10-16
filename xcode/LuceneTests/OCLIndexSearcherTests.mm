//
//  OCLIndexSearcherTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/16/13.
//
//

#import <XCTest/XCTest.h>
#import "OBJCLucene.h"

@interface OCLIndexSearcherTests : XCTestCase

@property (nonatomic, strong) NSString *path;

@property (nonatomic, strong) OCLIndexReader *indexReader;
@property (nonatomic, strong) OCLIndexWriter *indexWriter;

@end

@implementation OCLIndexSearcherTests

- (void)setUp
{
    [super setUp];
    NSString *cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDirectory, YES)[0];
    self.path = [cacheDirectory stringByAppendingPathComponent:@"test.index"];
    
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    
    self.indexWriter = [[OCLIndexWriter alloc] initWithPath:self.path overwrite:NO];
    self.indexReader = [[OCLIndexReader alloc] initWithPath:self.path];
    
    [self.indexReader close];
    [self.indexWriter open];
    for(int i=0; i!=10; i++) {
        OCLDocument *document = [[OCLDocument alloc] init];
        [document addFieldForKey:@"id" value:[NSString stringWithFormat:@"%d", i] tokenized:NO];
        [document addFieldForKey:@"f" value:[NSString stringWithFormat:@"%d", i%2] tokenized:NO];
        [self.indexWriter addDocument:document];
    }
    [self.indexWriter close];
    [self.indexReader open];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testQuerySearch
{
    OCLIndexSearcher *searcher = [[OCLIndexSearcher alloc] initWithIndexReader:self.indexReader];
    OCLTermQuery *query = [[OCLTermQuery alloc] initWithTerm:[[OCLTerm alloc] initWithField:@"f" text:@"0" internField:YES]];
    NSArray *documents = [searcher search:query];
    NSUInteger count = documents.count;
    NSUInteger expectedCount = 5;
    XCTAssertEqual(count, expectedCount, @"");
    NSMutableSet *foundDocuments = [NSMutableSet setWithObjects:@"0", @"2", @"4", @"6", @"8", nil];
    for(OCLDocument *document in documents) {
        [foundDocuments removeObject:[[document fieldForKey:@"id"] value]];
    }
    NSUInteger missingDocumentCount = foundDocuments.count;
    NSUInteger expectedMissingDocumentCount = 0;
    XCTAssertEqual(missingDocumentCount, expectedMissingDocumentCount, @"");
}

@end
