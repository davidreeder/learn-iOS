//
//  PhotoTagsTVC.m
//  Adapted from Paul Hegarty's Shutterbug example.
//
//  Initiates JSON fetch in model, then processes photo tags.
//

#import "PhotoTagsTVC.h"



//-------------------------------------------- -o--
@interface PhotoTagsTVC()

  @property  (nonatomic, strong)  NSArray     *photoTagsSorted;
  @property  (nonatomic)          PFCategory   currentFetchCategory;


  //
  - (NSString *) titleForRow:    (NSUInteger) row;
  - (NSString *) subtitleForRow: (NSUInteger) row;
  
  - (void) fetchPhotos: (PFCategory)fetchCategory;

@end




//-------------------------------------------- -o--
@implementation PhotoTagsTVC

#pragma mark - Constructors.

//----------------------- -o-
- (void) viewDidLoad
{
  [super viewDidLoad];

  [self showStanfordTags:nil];  // Default tags at startup.


  //
  [self.refreshControl addTarget: self
                          action: @selector(refreshTags:)
                forControlEvents: UIControlEventValueChanged ];

} // viewDidLoad



//----------------------- -o-
- (void) viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  // XXX  Should also propagate title string to UITabBarItem entry.
  //
  self.navigationItem.title = PF_PHOTOTAGSVC_TITLE;
    

  //
  [UIView animateWithDuration: PF_TABBAR_FADETIME
		   animations: ^{
		     [self.navigationController setToolbarHidden:NO animated:YES];
		      self.navigationController.toolbar.alpha = 1;
                   } ];
}


 
//----------------------- -o-
// fetchPhotos:
//
// Initiate fetch of photo meta data, store in model.
// Retreive tags from model.
//
- (void) fetchPhotos: (PFCategory)fetchCategory
{
  self.currentFetchCategory = fetchCategory;


  //
  [self.refreshControl beginRefreshing];

  dispatch_async(DP_ASYNC_QUEUE(@"for fetching tags"), 
  ^{
    [Zed networkIndicatorEnable:YES];
    [PhotoFetch fetchPhotos:fetchCategory];
    [Zed networkIndicatorEnable:NO];

    self.photoTagsByOccurrence = [PhotoFetch tagOccurrenceCount];

    dispatch_async(dispatch_get_main_queue(), ^{
      [self.tableView reloadData]; 
      [self.refreshControl endRefreshing];
    }); 

  }); 

} // fetchPhotos: 



//-------------------------------------------- -o--
#pragma mark - Getters/setters.

//----------------------- -o-
- (void) setPhotoTagsByOccurrence: (NSDictionary *)photoTagsByOccurrence
{
  _photoTagsByOccurrence = photoTagsByOccurrence;
  self.photoTagsSorted = [[self.photoTagsByOccurrence allKeys] sortedArrayUsingComparator:DP_BLOCK_CMPSTR_LOCINS_LT];
}



//-------------------------------------------- -o--
#pragma mark - Segue.

//----------------------- -o-
- (void) prepareForSegue: (UIStoryboardSegue *)segue    
                  sender: (id)sender
{
  if ([sender isKindOfClass:[UITableViewCell class]]) 
  {
    NSIndexPath  *indexPath = [self.tableView indexPathForCell:sender];

    if (indexPath) 
    {
      if ([segue.identifier isEqualToString:@"ShowImageCategory"]) 
      {
        [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];

        // Set search tag.
        // Indicate VC is NOT to be used to show recent photos.
        //
        if ([segue.destinationViewController respondsToSelector:@selector(setPhotoSearchTag:)]) 
        {
          [segue.destinationViewController 
                        performSelector: @selector(setPhotoSearchTag:) 
                             withObject: [[self titleForRow:indexPath.row] lowercaseString]];

          [segue.destinationViewController 
                        performSelector: @selector(setNotRecentsList:) 
                             withObject: [NSNumber numberWithBool:YES]];
        }
      } 
    } 
  } 
}



//-------------------------------------------- -o--
#pragma mark - UITableView datasource.


//----------------------- -o-
- (NSInteger)   tableView: (UITableView *)tableView  
    numberOfRowsInSection: (NSInteger)section
{
  return [self.photoTagsSorted count];
}


//----------------------- -o-
- (UITableViewCell *) tableView: (UITableView *)tableView
          cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
  static NSString  *cellIdentifier  = @"ImageTag";
  UITableViewCell  *cell            = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  
  //
  cell.textLabel.text        = [self titleForRow:indexPath.row];
  cell.detailTextLabel.text  = [self subtitleForRow:indexPath.row];
  
  return cell;
}




//-------------------------------------------- -o--
#pragma mark - Target/action.

//----------------------- -o-
- (IBAction) refreshTags: (UIBarButtonItem *)sender 
{
  [self fetchPhotos:self.currentFetchCategory];
}


//----------------------- -o-
- (IBAction) showStanfordTags: (UIBarButtonItem *)sender 
{
  [self fetchPhotos:PFCategoryStanford];
}


//----------------------- -o-
- (IBAction) showLatestGeoTags: (UIBarButtonItem *)sender
{
  [self fetchPhotos:PFCategoryLatestGeoreferenced];
}



//-------------------------------------------- -o--
#pragma mark - Helper methods.

//----------------------- -o-
- (NSString *) titleForRow: (NSUInteger)row
{
  return [self.photoTagsSorted[row] capitalizedString];
}


//----------------------- -o-
- (NSString *) subtitleForRow: (NSUInteger)row
{
  NSInteger  numPhotos = [[self.photoTagsByOccurrence objectForKey:self.photoTagsSorted[row]] integerValue];

  NSString  *s = [NSString stringWithFormat:@"(%ld photo%@)", 
                   (long)numPhotos, (numPhotos > 1) ? @"s" : @"" ];
  return s;
}


@end
