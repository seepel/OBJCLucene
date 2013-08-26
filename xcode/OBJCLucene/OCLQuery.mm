//
//  OCLQuery.m
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "OCLQuery.h"
#import "NSString+OCL.h"
#import "OCLIndexReaderPrivate.h"
#import "OCLDocumentPrivate.h"
#import "FieldSelector.h"

class LoadFieldByName : public FieldSelector {
public:
    const TCHAR *name;
    
    LoadFieldByName(const TCHAR *inFieldName) {
        name = inFieldName;
    }
    
	~LoadFieldByName() {};
    
	FieldSelectorResult accept(const TCHAR* fieldName) const {
        if(wcscmp(fieldName, name) == 0) {
            return LOAD;
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

- (NSArray *)findFieldValuesForName:(NSString *)inName withIndex:(OCLIndexReader *)inReader
{
    IndexReader *reader = [inReader cppIndexReader];
    IndexSearcher s(reader);
    
    NSMutableArray *array = [NSMutableArray array];
    FieldByNameCollector fieldCollector([inName toTCHAR], reader);
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

@end
