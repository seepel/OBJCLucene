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
#import "NSString+OCL.h"
#import "OCLTermPrivate.h"

@interface OCLIndexReader ()
@property (strong) NSString *path;
@end


@implementation OCLIndexReader {
    IndexReader *_indexReader;
}

- (id)initWithPath:(NSString *)inPath
{
    if((self = [super init])) {
        self.path = inPath;
        
        if([[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
            try {
                _indexReader = IndexReader::open([inPath cStringUsingEncoding:NSASCIIStringEncoding]);
            } catch (CLuceneError& t) {
                NSLog(@"Exception: %@", [NSString stringWithCString:t.what() encoding:[NSString defaultCStringEncoding]]);
                _indexReader = NULL;
            }
        } else {
            _indexReader = NULL;
        }
    }
    
    return self;
}

- (void)dealloc
{
    if(_indexReader != NULL) {
        _indexReader->close();
        _CLVDELETE(_indexReader);
    }
}

- (IndexReader *)cppIndexReader
{
    return _indexReader;
}

- (NSUInteger)numberOfDocuments
{
    if(_indexReader == NULL)
        return 0;
    
    return _indexReader->numDocs();
}

- (OCLDocument *)documentAtIndex:(NSInteger)inIndex
{
    if(_indexReader == NULL)
        return nil;

    Document doc;
    BOOL hasDoc = _indexReader->document(inIndex, doc, NULL);
    
    if(hasDoc) {
        OCLDocument *newDoc = [[OCLDocument alloc] init];
        [newDoc setCPPDocument:&doc];
        return newDoc;
    }
    
    return nil;
}

- (NSInteger)removeDocumentsWithFieldForKey:(NSString *)inFieldKey matchingValue:(NSString *)inValue
{
    const TCHAR *fieldName = [inFieldKey copyToTCHAR];
    const TCHAR *value = [inValue copyToTCHAR];
    
    Term *term = _CLNEW Term(fieldName, value);
    NSInteger removed = _indexReader->deleteDocuments(term);
    _CLDECDELETE(term);
    
    free((void *)fieldName);
    free((void *)value);
    
    return removed;
}

- (NSInteger)removeDocumentsWithFieldForKey:(NSString *)inFieldKey matchingValues:(NSArray *)inValues
{
    const TCHAR *fieldName = [inFieldKey copyToTCHAR];
    
    NSInteger removed = 0;
    Term *term = _CLNEW Term();
    for(NSString *string in inValues) {
        const TCHAR *value = [string copyToTCHAR];
        term->set(fieldName, value);
        removed += _indexReader->deleteDocuments(term);
        free((void *)value);
    }
    _CLDECDELETE(term);
    
    free((void *)fieldName);
    
    return removed;
}

- (void)close
{
    if(_indexReader != NULL) {
        _indexReader->close();
        _CLVDELETE(_indexReader);
    }
}

- (BOOL)open
{
    if(_indexReader == NULL) {
        if([[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
            try {
                _indexReader = IndexReader::open([self.path cStringUsingEncoding:NSASCIIStringEncoding]);
            } catch (CLuceneError& t) {
                NSLog(@"Exception: %@", [NSString stringWithCString:t.what() encoding:[NSString defaultCStringEncoding]]);
                _indexReader = NULL;
            }
        } else {
            _indexReader = NULL;
        }
        
        return (_indexReader != NULL);
    }
    
    return NO;
}

+ (void)unlockIndexAtPath:(NSString *)inPath
{
    IndexReader::unlock([inPath cStringUsingEncoding:NSASCIIStringEncoding]);
}

+ (BOOL)indexAtPathIsLocked:(NSString *)inPath
{
    return IndexReader::isLocked([inPath cStringUsingEncoding:NSASCIIStringEncoding]);
}

- (NSArray *)terms
{
    NSMutableArray *result = [NSMutableArray array];
    if(_indexReader == NULL) {
        return nil;
    }
    TermEnum *terms = _indexReader->terms();
    while (terms->next()) {
        Term *term = terms->term();
        OCLTerm *oclTerm = [[OCLTerm alloc] initWithField:[NSString stringFromTCHAR:term->field()]
                                                     text:[NSString stringFromTCHAR:term->text()]
                                              internField:YES];
        [result addObject:oclTerm];
    }
    return result;
}

    - (NSArray *)terms:(OCLTerm *)term
    {
        NSMutableArray *result = [NSMutableArray array];
        if(_indexReader == NULL) {
            return nil;
        }
        TermEnum *terms = _indexReader->terms([term cppTerm]);
        while (terms->next()) {
            Term *term = terms->term();
            OCLTerm *oclTerm = [[OCLTerm alloc] initWithField:[NSString stringFromTCHAR:term->field()]
                                                      text:[NSString stringFromTCHAR:term->text()]
                                               internField:YES];
            [result addObject:oclTerm];
        }
        return result;
    }

@end
