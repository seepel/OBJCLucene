//
//  OCLDocument.m
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "OCLDocument.h"
#import "NSString+OCL.h"
#import "OCLFieldPrivate.h"

@implementation OCLDocument {
    Document *_document;
}

- (id)init
{
    if((self = [super init])) {
        _document = _CLNEW Document();
        _document->clear();
    }
    
    return self;
}

- (void)dealloc
{
    _CLVDELETE(_document);
}

- (void)setCPPDocument:(Document *)inDocument
{
    _document->clear();
    
    const Document::FieldsType *fields = inDocument->getFields();
    for (Field *field : *fields)
    {
        BOOL isTokenized = field->isTokenized();
        int config = (isTokenized) ? Field::STORE_YES | Field::INDEX_TOKENIZED : Field::STORE_YES | Field::INDEX_UNTOKENIZED;
        _document->add(*_CLNEW Field(field->name(), field->stringValue(), config));
    }
}

- (Document *)cppDocument
{
    return _document;
}

- (void)addFieldForKey:(NSString *)inKey value:(NSString *)inValue tokenized:(BOOL)inTokenized
{
    int config = (inTokenized) ? (Field::STORE_YES | Field::INDEX_TOKENIZED) : (Field::STORE_YES | Field::INDEX_UNTOKENIZED);
    _document->add(*_CLNEW Field([inKey toTCHAR], [inValue toTCHAR], config));
}

- (void)removeFieldForKey:(NSString *)inKey
{
    _document->removeField([inKey toTCHAR]);
}

- (OCLField *)fieldForKey:(NSString *)inKey
{
    Field *field = _document->getField([inKey toTCHAR]);
    if(field == NULL)
        return nil;
    
    return [OCLField fieldWithKey:[NSString stringFromTCHAR:field->name()] value:[NSString stringFromTCHAR:field->stringValue()] tokenized:field->isTokenized()];
}

- (void)clear
{
    _document->clear();
}

@end
