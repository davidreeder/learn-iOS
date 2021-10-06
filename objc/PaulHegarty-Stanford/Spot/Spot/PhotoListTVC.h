//
//  PhotoListTVC.h
//  Adapted from Paul Hegarty's Shutterbug example.
//
//  Will call setImageURL: as part of any "ShowImage" segue.
//

#import <UIKit/UIKit.h>

#import "FlickrFetcher.h"
#import "PhotoFetch.h"
#import "ImageViewController.h"

#import "Danaprajna.h"



//-------------------------------------------- -o-
@interface PhotoListTVC : UITableViewController

  @property  (strong, nonatomic)  NSString  *photoSearchTag;

  @property  (strong, nonatomic)  NSArray   *photoArray;  // of NSDictionary
      // Photos with photoSearchTag  -OR-  from [PhotoFetch recentPhotos]

  @property  (nonatomic, getter=isNotRecentsList)  BOOL  notRecentsList;
      // YES in segue for category photos; NO for list most recently viewed photos.


  //
  - (IBAction) clearAllRecents: (UIBarButtonItem *)sender;

@end

