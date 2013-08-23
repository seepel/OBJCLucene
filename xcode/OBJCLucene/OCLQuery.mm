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

- (NSArray *)executeWithIndex:(OCLIndexReader *)inReader
{
    IndexReader *reader = [inReader cppIndexReader];
    IndexSearcher s(reader);

    Hits* h = s.search(_query);
    NSMutableArray *array = [NSMutableArray array];
    for (size_t i = 0;i <h->length(); i++){
        Document* doc = &h->doc(i);
        OCLDocument *newDoc = [[OCLDocument alloc] init];
        [newDoc setCPPDocument:doc];
        [array addObject:newDoc];
    }
    
    _CLVDELETE(h);
    
    return array;
}

@end
