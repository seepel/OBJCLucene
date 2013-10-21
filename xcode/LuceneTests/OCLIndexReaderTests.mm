//
//  OCLIndexReaderTests.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/16/13.
//
//

#import <XCTest/XCTest.h>
#import "OBJCLucene.h"
#import "OCLIndexReaderPrivate.h"
#import "OCLDocumentPrivate.h"
#import "Directory.h"
#import "NSString+OCL.h"

@interface OCLIndexReaderTests : XCTestCase

@property (nonatomic, strong) NSString *path;

@property (nonatomic, strong) OCLIndexReader *indexReader;
@property (nonatomic, strong) OCLIndexWriter *indexWriter;

@end

@implementation OCLIndexReaderTests

- (void)setUp
{
    [super setUp];
    NSString *cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDirectory, YES)[0];
    self.path = [cacheDirectory stringByAppendingPathComponent:@"test.index"];
    
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    
    self.indexWriter = [[OCLIndexWriter alloc] initWithPath:self.path overwrite:NO];
    self.indexReader = [[OCLIndexReader alloc] initWithPath:self.path];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInitialization
{
    XCTAssertFalse([self.indexReader cppIndexReader] == NULL, @"");
}

- (void)testLocked
{
    [self.indexReader cppIndexReader]->directory()->makeLock(IndexWriter::WRITE_LOCK_NAME);
    XCTAssertTrue([OCLIndexReader indexAtPathIsLocked:self.path] , @"");
}

- (void)testNumberOfDocuments
{
    OCLDocument *document = [[OCLDocument alloc] init];
    [document addFieldForKey:@"f" value:@"t" tokenized:NO];
    [self.indexReader close];
    [self.indexWriter open];
    [self.indexWriter addDocument:document];
    [self.indexWriter close];
    [self.indexReader open];
    NSUInteger result = [self.indexReader numberOfDocuments];
    NSUInteger expected = 1;
    XCTAssertEqual(result, expected, @"");
}

- (void)testTokenizedDocument
{
    OCLDocument *document = [[OCLDocument alloc] init];
    [document addFieldForKey:@"f" value:@"t1 t2" tokenized:YES];
    [self.indexReader close];
    [self.indexWriter open];
    [self.indexWriter addDocument:document];
    [self.indexWriter close];
    [self.indexReader open];
    NSArray *result = [self.indexReader terms];
    NSArray *expected = @[ [[OCLTerm alloc] initWithField:@"f" text:@"t1" internField:YES],
                           [[OCLTerm alloc] initWithField:@"f" text:@"t2" internField:YES] ];
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testRemoveDocuments
{
    OCLDocument *document1 = [[OCLDocument alloc] init];
    [document1 addFieldForKey:@"f" value:@"t" tokenized:NO];
    
    [self.indexReader close];
    [self.indexWriter open];
    [self.indexWriter addDocument:document1];
    [self.indexWriter close];
    [self.indexReader open];
    
    [self.indexReader removeDocumentsWithFieldForKey:@"f" matchingValue:@"t"];
    
    NSUInteger result = [self.indexReader numberOfDocuments];
    NSUInteger expected = 0;
    
    XCTAssertEqual(result, expected, @"");
}

- (void)testDocumentAtIndex
{
    OCLDocument *document = [[OCLDocument alloc] init];
    [document addFieldForKey:@"f" value:@"t" tokenized:NO];
    
    [self.indexReader close];
    [self.indexWriter open];
    [self.indexWriter addDocument:document];
    [self.indexWriter close];
    [self.indexReader open];
    
    NSString *result = [NSString stringFromTCHAR:[[self.indexReader documentAtIndex:0] cppDocument]->toString()];
    NSString *expected = [NSString stringFromTCHAR:[document cppDocument]->toString()];
    XCTAssertEqualObjects(result, expected, @"");
    
}

- (void)testNoStopWords
{
    
    NSString *cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDirectory, YES)[0];
    self.path = [cacheDirectory stringByAppendingPathComponent:@"testNoStop.index"];
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    
    OCLIndexWriter *indexWriter = [[OCLIndexWriter alloc] initWithPath:self.path overwrite:NO stopWords:@[ ]];
    
    OCLIndexReader *indexReader = [[OCLIndexReader alloc] initWithPath:self.path];
    
    OCLDocument *document = [[OCLDocument alloc] init];
    [document addFieldForKey:@"f" value:@"will test" tokenized:YES];
    
    [indexReader close];
    [indexWriter open];
    [indexWriter addDocument:document];
    [indexWriter close];
    [indexReader open];
    
    NSArray *result = [indexReader terms];
    NSArray *expected = @[ [[OCLTerm alloc] initWithField:@"f" text:@"test" internField:YES],
                           [[OCLTerm alloc] initWithField:@"f" text:@"will" internField:YES] ];
    XCTAssertEqualObjects(result, expected, @"");
}

- (void)testCustomStopWord
{
    
    NSString *cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDirectory, YES)[0];
    self.path = [cacheDirectory stringByAppendingPathComponent:@"testNoStop.index"];
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    
    OCLIndexWriter *indexWriter = [[OCLIndexWriter alloc] initWithPath:self.path overwrite:NO stopWords:@[ @"test" ]];
    
    OCLIndexReader *indexReader = [[OCLIndexReader alloc] initWithPath:self.path];
    
    OCLDocument *document = [[OCLDocument alloc] init];
    [document addFieldForKey:@"f" value:@"will test" tokenized:YES];
    
    [indexReader close];
    [indexWriter open];
    [indexWriter addDocument:document];
    [indexWriter close];
    [indexReader open];
    
    NSArray *result = [indexReader terms];
    NSArray *expected = @[ [[OCLTerm alloc] initWithField:@"f" text:@"will" internField:YES] ];
    XCTAssertEqualObjects(result, expected, @"");
}

@end
