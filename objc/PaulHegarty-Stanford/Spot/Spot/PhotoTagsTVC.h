//
//  PhotoTagsTVC.h
//  Adapted from Paul Hegarty's Shutterbug example.
//

#import <UIKit/UIKit.h>

#import "FlickrFetcher.h"
#import "PhotoFetch.h"

#import "Danaprajna.h"



//-------------------------------------------- -o-
#define PF_PHOTOTAGSVC_TITLE      @"Photo Categories"



//-------------------------------------------- -o-
@interface PhotoTagsTVC : UITableViewController

  @property  (nonatomic, strong)  NSDictionary  *photoTagsByOccurrence;
      // NB  Drives population of UITableView rows.


  //
  - (IBAction) refreshTags:        (UIBarButtonItem *)sender;

  - (IBAction) showStanfordTags:   (UIBarButtonItem *)sender;
  - (IBAction) showLatestGeoTags:  (UIBarButtonItem *)sender;

@end

