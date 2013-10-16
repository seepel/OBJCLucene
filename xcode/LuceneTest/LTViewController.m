//
//  LTViewController.m
//  LuceneTest
//
//  Created by Bob Van Osten on 8/22/13.
//
//

#import "LTViewController.h"
#import "OBJCLucene.h"

#define USE_FIELD_SEARCH 1

@interface LTViewController ()

@end

@implementation LTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    self.indexPath = [basePath stringByAppendingPathComponent:@"SearchIndex"];
    
//    OCLIndexWriter *writer = [[OCLIndexWriter alloc] initWithPath:self.indexPath overwrite:YES];
//    writer.useCompoundFile = NO;
    
    NSString* text_file = [[NSBundle mainBundle] pathForResource:@"us_cities" ofType:@"txt"];
    NSString* fileContents = [NSString stringWithContentsOfFile:text_file encoding:NSUTF8StringEncoding error:nil];
    NSArray* allCities = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSInteger index = 0;
//    OCLDocument *document = [[OCLDocument alloc] init];

//    for(NSString *city in allCities) {
//        [document clear];
//        [document addFieldForKey:@"index" value:[NSString stringWithFormat:@"%d", index] tokenized:NO];
//        [document addFieldForKey:@"name" value:city tokenized:YES];
//        [writer addDocument:document];
        
//        index++;
//    }
    
//    [writer removeDocumentsWithFieldForKey:@"index" matchingValue:@"0"];
    
//    writer.useCompoundFile = YES;
//    [writer optimize:YES];
    
//    self.indexReader = [[OCLIndexReader alloc] initWithPath:self.indexPath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.searchResults)
        return [self.searchResults count];
    
    return [self.indexReader numberOfDocuments];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(self.searchResults && USE_FIELD_SEARCH) {
        cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        OCLDocument *doc;
        if(self.searchResults)
            doc = [self.searchResults objectAtIndex:indexPath.row];
        else
            doc = [self.indexReader documentAtIndex:indexPath.row];
        
        OCLField *field = [doc fieldForKey:@"name"];
        cell.textLabel.text = field.value;
    }
        
    return cell;
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.searchResults = [NSArray array];
    [self.tableView reloadData];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.searchResults = nil;
    [self.tableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if(searchString == nil || searchString.length == 0) {
        self.searchResults = [NSArray array];
        return YES;
    }
    
    NSString *term = @"";
    NSArray *components = [searchString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for(NSString *string in components) {
        if(string.length > 0) {
            if(term .length > 0) {
                term = [term stringByAppendingString:@" OR "];
            }
        
            NSString *escaped = [OCLQueryParser escapeString:string];
            term = [term stringByAppendingFormat:@"*%@* OR %@~", escaped, escaped];
        }
    }
    
    
    OCLQueryParser *queryParser = [[OCLQueryParser alloc] initWithQueryString:term forFieldKey:@"name"];
    queryParser.fuzzyMinSim = 0.4;
    queryParser.allowLeadingWildcard = YES;
    OCLQuery *query = [queryParser query];
    
#if USE_FIELD_SEARCH
    self.searchResults = [query findFieldValuesForKey:@"name" withIndex:self.indexReader];
#else
    self.searchResults = [query findDocumentsWithIndex:self.indexReader];
#endif
    
    return YES;
}

@end
