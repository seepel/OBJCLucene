//
//  OCLIndexSearcher.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLIndexSearcher.h"
#import "OCLIndexReaderPrivate.h"
#import "OCLQueryPrivate.h"
#import "OCLFilterPrivate.h"
#import "OCLHitsArray.h"
#import "IndexSearcher.h"

@interface OCLIndexSearcher () {
    IndexSearcher *indexSearcher_;
}

@property (nonatomic, strong) OCLIndexReader *indexReader;

@end

@implementation OCLIndexSearcher

- (id)initWithIndexReader:(OCLIndexReader *)indexReader
{
    if((self = [super init])) {
        self.indexReader = indexReader;
        indexSearcher_ = _CLNEW IndexSearcher([indexReader cppIndexReader]);
    }
    return self;
}

- (void)dealloc
{
    if(indexSearcher_ != NULL) {
        _CLVDELETE(indexSearcher_);
    }
}

- (NSArray *)search:(OCLQuery *)query
{
    return [self search:query filter:nil];
}

- (NSArray *)search:(OCLQuery *)query filter:(OCLFilter *)filter
{
    Hits *hits = NULL;
    if(filter != nil) {
        hits = indexSearcher_->search([query cppQuery], [filter cppFilter]);
    } else {
        hits  = indexSearcher_->search([query cppQuery]);
    }
    return [[OCLHitsArray alloc] initWithHits:hits];
}

@end
