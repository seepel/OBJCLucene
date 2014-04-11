//
//  OCLIndexSearcher.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLIndexSearcher.h"
#import "OCLQueryPrivate.h"
#import "OCLIndexReaderPrivate.h"
#import "OCLQueryPrivate.h"
#import "OCLFilterPrivate.h"
#import "OCLHitsArray.h"
#import "IndexSearcher.h"

@interface OCLIndexSearcher () {
    IndexSearcher *indexSearcher_;
}

@property (nonatomic, strong) OCLIndexReader *indexReader;
@property (nonatomic, strong) OCLFilter *filter;
@property (nonatomic, strong) OCLQuery *query;

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
    if(indexSearcher_ == nil) {
        return nil;
    }
    
    self.query = query;
    self.filter = filter;
    
    Hits *hits = NULL;
    @try {
        if(filter != nil) {
            if([query cppQuery] != NULL && [filter cppFilter] != NULL)
                hits = indexSearcher_->search([query cppQuery], [filter cppFilter]);
        } else {
            if([query cppQuery] != NULL)
                hits  = indexSearcher_->search([query cppQuery]);
        }
        
    } @catch (...) {
        NSLog(@"Error searching");
    }
    
    if(hits != NULL)
        return [[OCLHitsArray alloc] initWithHits:hits];
    
    return nil;
}

@end
