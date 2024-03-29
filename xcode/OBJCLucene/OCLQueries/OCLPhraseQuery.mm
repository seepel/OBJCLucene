//
//  OCLPhraseQuery.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLPhraseQuery.h"
#import "OCLQueryPrivate.h"
#import "OCLTermPrivate.h"
#import "PhraseQuery.h"

@interface OCLPhraseQuery () {
    NSMutableArray *terms_;
}

@end

@implementation OCLPhraseQuery

- (id)init
{
    if((self = [super init])) {
        PhraseQuery *query = _CLNEW PhraseQuery();
        [self setCPPQuery:query];
        terms_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithTerms:(NSArray *)terms slop:(NSUInteger)slop
{
    if((self = [self init])) {
        self.slop = slop;
        for(OCLTerm *term in terms) {
            [self addTerm:term];
        }
    }
    return self;
}

- (void)setSlop:(int32_t)slop
{
    PhraseQuery *cppQuery = (PhraseQuery *)[self cppQuery];
    cppQuery->setSlop(slop);
}

- (int32_t)slop
{
    PhraseQuery *cppQuery = (PhraseQuery *)[self cppQuery];
    return cppQuery->getSlop();
}

- (void)addTerm:(OCLTerm *)term
{
    PhraseQuery *cppQuery = (PhraseQuery *)[self cppQuery];
    cppQuery->add([term cppTerm]);
    [terms_ addObject:term];
}

@end

