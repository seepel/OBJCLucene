//
//  OCLQueryPrivate.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "OCLQuery.h"

@class OCLTerm;

@interface OCLQuery (Private)

- (void)setCPPQuery:(lucene::search::Query *)inQuery;
- (lucene::search::Query *)cppQuery;

@end
