//
//  LTViewController.h
//  LuceneTest
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import <UIKit/UIKit.h>

@class OCLIndexReader;

@interface LTViewController : UITableViewController

@property (strong) NSString *indexPath;
@property (strong) OCLIndexReader *indexReader;
@property (strong) NSArray *searchResults;

@end
