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
    standard::StandardAnalyzer *_analyzer;
    std::vector<const TCHAR *> _stopWords;
}

@synthesize maxFieldLength = _maxFieldLength;
@synthesize useCompoundFile = _useCompoundFile;

- (id)initWithPath:(NSString *)inPath overwrite:(BOOL)inOverwrite
{
    return [self initWithPath:inPath overwrite:inOverwrite stopWords:nil];
}

- (id)initWithPath:(NSString *)inPath overwrite:(BOOL)inOverwrite stopWords:(NSArray *)inStopWords
{
    if((self = [super init])) {
        self.path = inPath;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL exists = [fileManager fileExistsAtPath:inPath];
        if(!exists && !inOverwrite) {
            inOverwrite = true;
        }
        
        if(inOverwrite && exists) {
            if([[NSFileManager defaultManager] contentsOfDirectoryAtPath:inPath error:nil].count == 0) {
                [[NSFileManager defaultManager] removeItemAtPath:inPath error:nil];
            }
        }
        
        if(inOverwrite) {
            if(![[NSFileManager defaultManager] fileExistsAtPath:inPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:inPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
        

        try {
            if(inStopWords != nil) {
                std::vector<const TCHAR *> stopWords;
                for(NSString *stopWord in inStopWords) {
                    stopWords.push_back([stopWord toTCHAR]);
                }
                stopWords.push_back(NULL);
                _analyzer = new standard::StandardAnalyzer(&stopWords[0]);
            } else {
                _analyzer = new standard::StandardAnalyzer();
            }
            
            _indexWriter = new IndexWriter([inPath cStringUsingEncoding:NSASCIIStringEncoding], _analyzer, inOverwrite);
        } catch (CLuceneError& t) {
            NSLog(@"Exception: %@", [NSString stringWithCString:t.what() encoding:[NSString defaultCStringEncoding]]);
            _indexWriter = NULL;
        }
                
        if(_indexWriter != NULL) {
            _indexWriter->setMaxFieldLength(0x7FFFFFFFL);
            _indexWriter->setMaxMergeDocs(0x7FFFFFFFL);
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
    if(_analyzer != NULL) {
        _CLVDELETE(_analyzer);
    }
}

- (void)close
{
    if(_indexWriter != NULL) {
        _indexWriter->close();
        _CLVDELETE(_indexWriter);
    }
}

- (BOOL)open
{
    if(_indexWriter == NULL) {
        BOOL overwrite = ![[NSFileManager defaultManager] fileExistsAtPath:self.path];
        
        try {
            _indexWriter = new IndexWriter([self.path cStringUsingEncoding:NSASCIIStringEncoding], _analyzer, overwrite);
        } catch (CLuceneError& t) {
            NSLog(@"Exception: %@", [NSString stringWithCString:t.what() encoding:[NSString defaultCStringEncoding]]);
            _indexWriter = NULL;
        }
        
        if(_indexWriter != NULL) {
            _indexWriter->setMaxFieldLength(0x7FFFFFFFL);
        }
    }
    
    return (_indexWriter != nil);
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
