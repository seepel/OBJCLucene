//
//  OCLTerm.m
//  OBJCLucene
//
//  Created by Sean Lynch on 9/20/13.
//
//

#import "OCLTerm.h"
#import "NSString+OCL.h"

@implementation OCLTerm {
    Term *_term;
}

- (id)initWithField:(NSString *)field text:(NSString *)text internField:(BOOL)internField
{
    if((self = [super init])) {
        const TCHAR *tField = [field toTCHAR];
        const TCHAR *tText = [text toTCHAR];
        Term *term = _CLNEW Term(tField, tText, (bool)internField);
        [self setCPPTerm:term];
    }
    
    return self;
}

- (void)setCPPTerm:(Term *)inTerm
{
    if(_term != NULL) {
        _CLVDELETE(_term);
    }
    _term = inTerm;
}

- (void)dealloc
{
    if(_term != NULL) {
        _CLVDELETE(_term);
    }
}

- (BOOL)isEqual:(id)object
{
    if(![object isKindOfClass:[self class]]) {
        return NO;
    }
    if([self hash] != [object hash]) {
        return NO;
    }
    return [self cppTerm]->equals([object cppTerm]);
}

- (NSUInteger)hash
{
    if(_term == NULL) {
        return 0;
    }
    return _term->hashCode();
}

- (NSString *)description
{
    if(_term == NULL) {
        return [super description];
    }
    return [NSString stringWithFormat:@"%@ - %@", [super description], [NSString stringFromTCHAR:_term->toString()]];
}

- (Term *)cppTerm
{
    return _term;
}

- (NSString *)field
{
    return [NSString stringFromTCHAR:_term->field()];
}

- (NSString *)text
{
    return [NSString stringFromTCHAR:_term->text()];
}

@end
