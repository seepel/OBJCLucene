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
    NSArray *terms_;
}

@end

@implementation OCLPhraseQuery

- (id)initWithTerms:(NSArray *)terms slop:(NSUInteger)slop
{
    if((self = [super init])) {
        PhraseQuery *query = _CLNEW PhraseQuery();
        [self setCPPQuery:query];
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
}

@end

