//
//  OCLMultiPhraseQuery.m
//  OBJCLucene
//
//  Created by Sean Lynch on 10/15/13.
//
//

#import "OCLMultiPhraseQuery.h"
#import "OCLQueryPrivate.h"
#import "OCLTermPrivate.h"
#import "MultiPhraseQuery.h"

@interface OCLMultiPhraseQuery () {
    NSMutableArray *terms_;
}

@end

@implementation OCLMultiPhraseQuery

- (id)init
{
    if((self = [super init])) {
        MultiPhraseQuery *query = _CLNEW MultiPhraseQuery();
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
    MultiPhraseQuery *cppQuery = (MultiPhraseQuery *)[self cppQuery];
    cppQuery->setSlop(slop);
}

- (int32_t)slop
{
    MultiPhraseQuery *cppQuery = (MultiPhraseQuery *)[self cppQuery];
    return cppQuery->getSlop();
}

- (void)addTerm:(OCLTerm *)term
{
    MultiPhraseQuery *cppQuery = (MultiPhraseQuery *)[self cppQuery];
    cppQuery->add([term cppTerm]);
    [terms_ addObject:term];
}

@end
