//
//  OCLHitsArray.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLHitsArray.h"
#import "OCLDocumentPrivate.h"

@interface OCLHitsArray ( ) {
    Hits *hits_;
    NSMutableArray *documentCache_;
}

- (void)setHits:(Hits *)hits;

@end

@implementation OCLHitsArray

- (id)initWithHits:(lucene::search::Hits *)hits
{
    if((self = [super init])) {
        [self setHits:hits];
        documentCache_ = [NSMutableArray arrayWithCapacity:hits_->length()];
    }
    return self;
}

- (void)dealloc
{
    if(hits_ != NULL) {
        _CLVDELETE(hits_);
    }
}

- (void)setHits:(lucene::search::Hits *)hits
{
    if(hits_ != NULL) {
        _CLVDELETE(hits_);
    }
    hits_ = hits;
}

- (NSUInteger)count
{
    if(hits_ == NULL) {
        return 0;
    }
    return hits_->length();
}

- (id)objectAtIndex:(NSUInteger)index
{
    if(index < hits_->length()) {
        @throw [NSException exceptionWithName:NSRangeException reason:[NSString stringWithFormat:@"The requested index is outside of the receiver's range [0..%d]", self.count] userInfo:nil];
    }
    
    for(int i = documentCache_.count; i <= index; i++) {
        Document cppDocument = hits_->doc(i);
        OCLDocument *document = [[OCLDocument alloc] init];
        [document setCPPDocument:&cppDocument];
        [documentCache_ addObject:document];
    }
    
    return [documentCache_ objectAtIndex:index];
}

@end
