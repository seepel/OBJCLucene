//
//  OCLQuery.m
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "OCLQuery.h"
#import "OCLQueryPrivate.h"
#import "OCLTerm.h"
#import "OCLTermPrivate.h"
#import "NSString+OCL.h"
#import "OCLIndexReaderPrivate.h"
#import "OCLDocumentPrivate.h"
#import "FieldSelector.h"

#import "MatchAllDocsQuery.h"

#import "OCLBooleanQuery.h"
#import "OCLFuzzyQuery.h"
#import "OCLMultiPhraseQuery.h"
#import "OCLPhraseQuery.h"
#import "OCLPrefixQuery.h"
#import "OCLTermQuery.h"
#import "OCLWildcardQuery.h"



class LoadFieldByName : public FieldSelector {
public:
    const TCHAR *name;
    
    LoadFieldByName(const TCHAR *inFieldName) {
        name = inFieldName;
    }
    
	~LoadFieldByName() {};
    
	FieldSelectorResult accept(const TCHAR* fieldName) const {
        if(wcscmp(fieldName, name) == 0) {
            return LOAD_AND_BREAK;
        }
        return NO_LOAD;
    }
};

class FieldByNameCollector : public HitCollector {
public:
    IndexReader *indexReader;
    LoadFieldByName *fieldSelector;
	vector< pair<NSString *, float_t> > list;

	FieldByNameCollector(const TCHAR *name, IndexReader *reader) {
        fieldSelector = new LoadFieldByName(name);
        indexReader = reader;
	}
    
    ~FieldByNameCollector() {
        delete fieldSelector;
    }
    
	void collect(const int32_t doc, const float_t score) {
        Document document;
        indexReader->document(doc, document, fieldSelector);
        
        Field *field = document.getField(fieldSelector->name);
        list.push_back(make_pair([NSString stringFromTCHAR:field->stringValue()], score));
	}
};

template<template <typename> class P = greater >
struct compareScore {
    template<class T1, class T2> bool operator()(const pair<T1, T2>& left, const pair<T1, T2>& right) {
        return P<T2>()(left.second, right.second);
    }
};

@implementation OCLQuery {
    Query* _query;
}

- (void)dealloc
{
    _CLVDELETE(_query);
}

- (void)setCPPQuery:(Query *)inQuery
{
    if(_query != NULL) {
        _CLVDELETE(_query);
    }
    
    _query = inQuery;
}

- (Query *)cppQuery
{
    return _query;
}

- (float)boost
{
    Query *query = [self cppQuery];
    if(query == NULL) {
        return 0;
    }
    return query->getBoost();
}

- (void)setBoost:(float)boost
{
    Query *query = [self cppQuery];
    if(query == NULL) {
        return;
    }
    query->setBoost(boost);
}

- (BOOL)isEqual:(id)object
{
    if(![object isKindOfClass:[self class]]) {
        return NO;
    }
    if([self cppQuery] == NULL) {
        if([object cppQuery] == NULL) {
            return self == object;
        }
    }
    if([self hash] != [object hash]) {
        return NO;
    }
    return [self cppQuery]->equals([object cppQuery]);
}

- (NSUInteger)hash
{
    if([self cppQuery] == NULL) {
        return 0;
    }
    return [self cppQuery]->hashCode();
}

- (NSString *)description
{
    if(_query == NULL) {
        return [super description];
    }
    return [NSString stringWithFormat:@"%@ - %@", [super description], [NSString stringFromTCHAR:_query->toString()]];
}

- (NSArray *)findFieldValuesForKey:(NSString *)inKey withIndex:(OCLIndexReader *)inReader
{
    IndexReader *reader = [inReader cppIndexReader];
    IndexSearcher s(reader);
    
    NSMutableArray *array = [NSMutableArray array];
    FieldByNameCollector fieldCollector([inKey toTCHAR], reader);
    s._search(_query, NULL, &fieldCollector);
    
    vector< pair<NSString *, float_t> > v = fieldCollector.list;
    sort(v.begin(), v.end(), compareScore<>());
    
    for(auto pair : v) {
        [array addObject:pair.first];
    }
    
    return array;
}

- (NSArray *)findDocumentsWithIndex:(OCLIndexReader *)inReader
{
    IndexReader *reader = [inReader cppIndexReader];
    IndexSearcher s(reader);

    NSMutableArray *array = [NSMutableArray array];
    Hits* h = s.search(_query);
    for (size_t i = 0; i < h->length(); i++){
        Document* doc = &h->doc(i);
        OCLDocument *newDoc = [[OCLDocument alloc] init];
        [newDoc setCPPDocument:doc];
        [array addObject:newDoc];
    }
    
    _CLVDELETE(h);
    
    return array;
}

+ (id)booleanQueryWithClauses:(NSArray *)clauses
{
    return [[OCLBooleanQuery alloc] initWithClauses:clauses];
}

+ (id)constantScoreQueryWithFilter:(OCLFilter *)filter
{
#pragma message("Need to implement filters before we can create this query.")
    return nil;
}

+ (id)fuzzyQueryWithTerm:(OCLTerm *)term minimumSimilarity:(float)minimumSimilarity prefixLength:(NSUInteger)prefixLength
{
    return [[OCLFuzzyQuery alloc] initWithTerm:term minimumSimilarity:minimumSimilarity prefixLength:prefixLength];
}

+ (id)allDocsQuery
{
    OCLQuery *result = [[OCLQuery alloc] init];
    MatchAllDocsQuery *query = _CLNEW MatchAllDocsQuery();
    [result setCPPQuery:query];
    return result;
}

+ (id)multiPhraseQueryWithTerms:(NSArray *)terms slop:(NSUInteger)slop
{
    return [[OCLMultiPhraseQuery alloc] initWithTerms:terms slop:slop];
}

+ (id)phraseQueryWithTerms:(NSArray *)terms slop:(NSUInteger)slop
{
    return [[OCLPhraseQuery alloc] initWithTerms:terms slop:slop];
}

+ (id)prefixQueryWithTerm:(OCLTerm *)term
{
    return [[OCLPrefixQuery alloc] initWithTerm:term];
}

+ (id)termQueryWithTerm:(OCLTerm *)term
{
    return [[OCLTermQuery alloc] initWithTerm:term];
}


+ (id)wildcardQueryWithTerm:(OCLTerm *)term
{
    return [[OCLWildcardQuery alloc] initWithTerm:term];
}

@end
