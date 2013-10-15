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

- (void)setCPPQuery:(Query *)inQuery;
- (Query *)cppQuery;

@end
