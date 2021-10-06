//
// PhotoListTVC.m
//
// Manage UITableView for photos in a given category (with a given tag)
//   -AND-
// manage list of most recently viewed photos.
//  
// Adapted from Paul Hegarty's Shutterbug example.
//

#import "PhotoListTVC.h"



//-------------------------------------------- -o--
@interface PhotoListTVC() <UISplitViewControllerDelegate> 

  @property  (weak, nonatomic)  IBOutlet UIBarButtonItem  *cacheStatusButtonLabelOutput;
      // NB  This button repurposed simply to output text, UILabel-like.


  //
  - (NSString *) titleForRow:    (NSUInteger) row;
  - (NSString *) subtitleForRow: (NSUInteger) row;

  - (void) transferSplitViewBarButtonItemToViewController: (id)nextDetailVC;

  - (void) setCacheSizeFreeDisplayOutput;

@end




//-------------------------------------------- -o--
@implementation PhotoListTVC

#pragma mark - Constructors.

//----------------------- -o-
- (void) awakeFromNib
{
  self.splitViewController.delegate = self;
}


//----------------------- -o-
- (void) viewDidLoad
{
  [super viewDidLoad];

  if (self.isNotRecentsList) {
    self.photoArray = [PhotoFetch photoArrayPerTagOccurrence:self.photoSearchTag];

  } else {
    self.photoArray = [PhotoFetch recentPhotos];
    [self setCacheSizeFreeDisplayOutput];
  }

} // viewDidLoad



//----------------------- -o-
- (void) viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  static long long  currentFreeBytesPrevious  = -1;
  long long         currentFreeBytes          = [[PhotoFetch photoCache] currentFreeBytes];

  if ( (! self.isNotRecentsList) 
          && ([PhotoFetch areRecentPhotosUpdated] || (currentFreeBytesPrevious != currentFreeBytes)) )
  {
    self.photoArray = [PhotoFetch recentPhotos];
    [self setCacheSizeFreeDisplayOutput];

    currentFreeBytesPrevious = currentFreeBytes;
    [self.tableView reloadData];
  }


  //
  // NB  Both clauses needed for iPad.  iPhone needs only setToolbarHidden=YES.
  //
  if (self.isNotRecentsList) {
    [UIView animateWithDuration: PF_TABBAR_FADETIME
                     animations: ^{
                       [self.navigationController setToolbarHidden:YES animated:YES];
                       self.navigationController.toolbar.alpha = 0;
                     } ];

  } else {
    [UIView animateWithDuration: PF_TABBAR_FADETIME
                     animations: ^{
                       [self.navigationController setToolbarHidden:NO animated:YES];
                       self.navigationController.toolbar.alpha = 1;
                     } ];
  }


  //
  // XXX  Unprintable characters do not count in string length!
  //
  if ([((UINavigationItem *)self.navigationItem).title isEqualToString:@""])
  {
    ((UINavigationItem *)self.navigationItem).title = @"(untitled)";
  }

} // viewDidLayoutSubviews



//----------------------- -o-
- (void)  viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  [self.tableView reloadData];
}




//-------------------------------------------- -o--
#pragma mark - Getters/setters.


//----------------------- -o-
- (void) setPhotoArray: (NSArray *)photoArray
{
  // Recents list is already sorted by date.
  //
  if (! self.isNotRecentsList) { 
    _photoArray = photoArray;
    return; 
  }


  // Sort by title, then by description.
  //
  NSSortDescriptor  *sd1 = [[NSSortDescriptor alloc]  initWithKey:FLICKR_PHOTO_TITLE        ascending:YES  selector:@selector(caseInsensitiveCompare:)];
  NSSortDescriptor  *sd2 = [[NSSortDescriptor alloc]  initWithKey:FLICKR_PHOTO_DESCRIPTION  ascending:YES  selector:@selector(caseInsensitiveCompare:)];

  NSArray *sortDescriptorList = [NSArray arrayWithObjects:sd1, sd2, nil];

  _photoArray = [photoArray sortedArrayUsingDescriptors:sortDescriptorList];
}




//-------------------------------------------- -o--
#pragma mark - Target/action.

//----------------------- -o-
- (IBAction) clearAllRecents: (UIBarButtonItem *)sender 
{
  [PhotoFetch clearRecents];

  [self setCacheSizeFreeDisplayOutput];

  [self.tableView reloadData];
}




//-------------------------------------------- -o--
#pragma mark - Segue.

//----------------------- -o-
- (void) prepareForSegue: (UIStoryboardSegue *)segue 
                  sender: (id)sender
{
  if ([sender isKindOfClass:[UITableViewCell class]])
  {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

    if (indexPath) 
    {
      if ([segue.identifier isEqualToString:@"ShowImage"]) 
      {
        if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) 
        {
          NSURL *url;

          // For iPad, download largest photo.
          //
          if (self.splitViewController) {
            url = [FlickrFetcher urlForPhoto:self.photoArray[indexPath.row] format:FlickrPhotoFormatOriginal];
          } else {
            url = [FlickrFetcher urlForPhoto:self.photoArray[indexPath.row] format:FlickrPhotoFormatLarge];
          }

          [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
          [segue.destinationViewController setTitleText:[self titleForRow:indexPath.row]];
            
          [segue.destinationViewController setPhotoEntry:self.photoArray[indexPath.row]];
          [segue.destinationViewController setPhotoEntryFromRecentsList:(! self.isNotRecentsList)];


          // NB  Transfer barButton required for each replacement of detailVC.
          //
          if (self.splitViewController) {
            [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
          }
            
        }
      }
    } // endif -- indexPath
  }
    
} // prepareForSegue:sender:




//-------------------------------------------- -o--
#pragma mark - UITableView datasource.

//----------------------- -o-
- (NSInteger)   tableView: (UITableView *)tableView 
    numberOfRowsInSection: (NSInteger)section
{
  if (self.isNotRecentsList) { 
    return [self.photoArray count];
  } else {
    return (NSInteger) fmin([self.photoArray count], PF_RECENTS_MAX);
  }
}



//----------------------- -o-
- (UITableViewCell *) tableView: (UITableView *)tableView 
          cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
  static NSString  *cellIdentifier = @"ImageTitle";
  UITableViewCell  *cell           = 
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  
  //
  cell.textLabel.text        = [self titleForRow:indexPath.row];
  cell.detailTextLabel.text  = [self subtitleForRow:indexPath.row];

  return cell;
}




//-------------------------------------------- -o--
#pragma mark - UISplitViewController delegate.

//------------------ -o-
- (BOOL) splitViewController: (UISplitViewController *) sender 
    shouldHideViewController: (UIViewController *)      master
               inOrientation: (UIInterfaceOrientation)  orientation
{
  return UIInterfaceOrientationIsPortrait(orientation);
}


//------------------ -o-
- (void) splitViewController: (UISplitViewController *) sender
      willHideViewController: (UIViewController *)      master
           withBarButtonItem: (UIBarButtonItem *)       barButtonItem
        forPopoverController: (UIPopoverController *)   popover
{
  id  detailVC = [sender.viewControllers lastObject]; 

  if ([detailVC respondsToSelector:@selector(setSplitViewBarButtonItem:)])
  {
    barButtonItem.title = @"Photo List"; 
    [detailVC performSelector:@selector(setSplitViewBarButtonItem:) withObject:barButtonItem];
  }
}



//------------------ -o-
- (void) splitViewController: (UISplitViewController *) sender
      willShowViewController: (UIViewController *)      master
   invalidatingBarButtonItem: (UIBarButtonItem *)       barButtonItem
{
  id  detailVC = [sender.viewControllers lastObject];

  if ([detailVC respondsToSelector:@selector(setSplitViewBarButtonItem:)])
  {
    [detailVC performSelector:@selector(setSplitViewBarButtonItem:) withObject:nil];
  }
}



//-------------------------------------------- -o--
#pragma mark - Helper methods.

//----------------------- -o-
- (NSString *) titleForRow: (NSUInteger)row
{
    return [self.photoArray[row][FLICKR_PHOTO_TITLE] description];
}



//----------------------- -o-
- (NSString *) subtitleForRow: (NSUInteger)row
{
  NSString  *rowDescription   = [[self.photoArray[row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
  NSString  *cachedIndicator  = @"";

  if ([[PhotoFetch photoCache] isFileCached:PF_PHOTOENTRY_FILENAME(self.photoArray[row])])
  {
    cachedIndicator = @"[cached]  ";
  }

  return [NSString stringWithFormat:@"%@%@", cachedIndicator, rowDescription];
}



//------------------ -o-
// transferSplitViewBarButtonItemToViewController:
//
// Copy splitView bar button from old detailVC to the new detailVC.
//
// Lifted from Paul Hegarty lecture slides.
//
- (void)  transferSplitViewBarButtonItemToViewController: (id)nextDetailVC
{
  id  currentDetailVC = [self.splitViewController.viewControllers lastObject];

  if (![currentDetailVC respondsToSelector:@selector(setSplitViewBarButtonItem:)]
        || ![currentDetailVC respondsToSelector:@selector(splitViewBarButtonItem)]) 
  { 
    return;
  }


  //
  UIBarButtonItem  *splitViewBarButtonItem =
                        [currentDetailVC performSelector:@selector(splitViewBarButtonItem)];

  [currentDetailVC performSelector:@selector(setSplitViewBarButtonItem:) withObject:nil];

  if (splitViewBarButtonItem) {
    [nextDetailVC performSelector:@selector(setSplitViewBarButtonItem:) withObject:splitViewBarButtonItem];
  }

} // transferSplitViewBarButtonItemToViewController:



//----------------------- -o-
- (void) setCacheSizeFreeDisplayOutput
{
  self.cacheStatusButtonLabelOutput.title =
#if __LP64__
      [NSString stringWithFormat:@"Cache free: %ldk", 
#else
      [NSString stringWithFormat:@"Cache free: %dk", 
#endif
        ([[PhotoFetch photoCache] currentFreeBytes] / 1024) ];
}


@end

