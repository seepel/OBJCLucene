//
//  OCLIndexWriter.m
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "OCLIndexWriter.h"
#import "OCLDocumentPrivate.h"
#import "NSString+OCL.h"

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
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL exists = [fileManager fileExistsAtPath:inPath];
        if(!exists && !inOverwrite) {
            inOverwrite = true;
        }
                
        try {
            _indexWriter = new IndexWriter([inPath cStringUsingEncoding:NSASCIIStringEncoding], &_analyzer, inOverwrite);
        } catch (CLuceneError& t) {
            NSLog(@"Exception: %@", [NSString stringWithCString:t.what() encoding:[NSString defaultCStringEncoding]]);
            _indexWriter = NULL;
        }
        
        if(_indexWriter == NULL)
            return nil;
        
        if(_indexWriter != NULL) {
            _indexWriter->setMaxFieldLength(0x7FFFFFFFL);
        }
    }
    
    return self;
}

- (void)dealloc
{
    if(_indexWriter != NULL) {
        _indexWriter->close();
        _CLVDELETE(_indexWriter);
    }
}

- (void)close
{
    _indexWriter->close();
    _CLVDELETE(_indexWriter);
}

- (void)open
{
    if(_indexWriter == NULL) {
        BOOL overwrite = ![[NSFileManager defaultManager] fileExistsAtPath:self.path];
        
        try {
            _indexWriter = new IndexWriter([self.path cStringUsingEncoding:NSASCIIStringEncoding], &_analyzer, overwrite);
        } catch (CLuceneError& t) {
            NSLog(@"Exception: %@", [NSString stringWithCString:t.what() encoding:[NSString defaultCStringEncoding]]);
            _indexWriter = NULL;
        }
        
        if(_indexWriter != NULL) {
            _indexWriter->setMaxFieldLength(0x7FFFFFFFL);
        }
    }
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

- (void)removeDocumentsWithFieldForKey:(NSString *)inFieldKey matchingValue:(NSString *)inValue
{
    const TCHAR *fieldName = [inFieldKey copyToTCHAR];
    const TCHAR *value = [inValue copyToTCHAR];
    
    Term *term = _CLNEW Term(fieldName, value);
    _indexWriter->deleteDocuments(term);
    _CLDECDELETE(term);
    
    free((void *)fieldName);
    free((void *)value);
}

- (void)replaceDocumentsWithFieldForKey:(NSString *)inFieldKey matchingValue:(NSString *)inValue withDocument:(OCLDocument *)inDocument
{
    const TCHAR *fieldName = [inFieldKey copyToTCHAR];
    const TCHAR *value = [inValue copyToTCHAR];
    
    Term *term = _CLNEW Term(fieldName, value);
    _indexWriter->updateDocument(term, [inDocument cppDocument]);
    _CLDECDELETE(term);
    
    free((void *)fieldName);
    free((void *)value);
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
