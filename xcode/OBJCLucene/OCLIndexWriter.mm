//
//  OCLIndexWriter.m
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "OCLIndexWriter.h"
#import "OCLDocumentPrivate.h"

@interface OCLIndexWriter ()

@property (strong) NSString *path;

@end

@implementation OCLIndexWriter {
    IndexWriter *_indexWriter;
    standard::StandardAnalyzer _analyzer;
}

@synthesize maxFieldLength = _maxFieldLength;
@synthesize useCompoundFile = _useCompoundFile;

- (id)initWithPath:(NSString *)inPath overwrite:(BOOL)inOverwrite
{
    if((self = [super init])) {
        self.path = inPath;
        
        _indexWriter = new IndexWriter([inPath cStringUsingEncoding:NSASCIIStringEncoding], &_analyzer, inOverwrite);
        _indexWriter->setMaxFieldLength(0x7FFFFFFFL);
    }
    
    return self;
}

- (void)dealloc
{
    _indexWriter->close();
    delete _indexWriter;
}

- (void)setMaxFieldLength:(int32_t)maxFieldLength
{
    _maxFieldLength = maxFieldLength;
    _indexWriter->setMaxFieldLength(maxFieldLength);
}

- (void)setUseCompoundFile:(BOOL)useCompoundFile
{
    _useCompoundFile = useCompoundFile;
    _indexWriter->setUseCompoundFile(useCompoundFile);
}

- (void)addDocument:(OCLDocument *)inDocument
{
    Document *doc = [inDocument cppDocument];
    _indexWriter->addDocument(doc);
}

- (void)optimize:(BOOL)inWaitUntilDone
{
    _indexWriter->optimize(inWaitUntilDone);
}

- (void)flush
{
    _indexWriter->flush();
}

@end
