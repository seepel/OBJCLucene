//
//  OCLDocumentPrivate.h
//  clucene
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "OCLDocument.h"

@interface OCLDocument (Private)

- (Document *)cppDocument;
- (void)setCPPDocument:(Document *)inDocument;

@end
