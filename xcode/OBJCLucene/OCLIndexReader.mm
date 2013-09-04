//
//  OCLIndexReader.m
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "OCLIndexReader.h"
#import "OCLDocumentPrivate.h"
#import "FieldSelector.h"

@implementation OCLIndexReader {
    IndexReader *_indexReader;
}

- (id)initWithPath:(NSString *)inPath
{
    if((self = [super init])) {
        try {
            _indexReader = IndexReader::open([inPath cStringUsingEncoding:NSASCIIStringEncoding]);
        } catch (CLuceneError& t) {
            NSLog(@"Exception: %@", [NSString stringWithCString:t.what() encoding:[NSString defaultCStringEncoding]]);
            _indexReader = NULL;
        }
        
        if(_indexReader == NULL)
            return nil;
    }
    
    return self;
}

- (void)dealloc
{
    _indexReader->close();
    _CLVDELETE(_indexReader);
}

- (IndexReader *)cppIndexReader
{
    return _indexReader;
}

- (NSUInteger)numberOfDocuments
{
    return _indexReader->numDocs();
}

- (OCLDocument *)documentAtIndex:(NSInteger)inIndex
{
    Document doc;
    BOOL hasDoc = _indexReader->document(inIndex, doc, NULL);
    
    if(hasDoc) {
        OCLDocument *newDoc = [[OCLDocument alloc] init];
        [newDoc setCPPDocument:&doc];
        return newDoc;
    }
    
    return nil;
}

+ (void)unlockIndexAtPath:(NSString *)inPath
{
    IndexReader::unlock([inPath cStringUsingEncoding:NSASCIIStringEncoding]);
}

+ (BOOL)indexAtPathIsLocked:(NSString *)inPath
{
    return IndexReader::isLocked([inPath cStringUsingEncoding:NSASCIIStringEncoding]);
}

@end
