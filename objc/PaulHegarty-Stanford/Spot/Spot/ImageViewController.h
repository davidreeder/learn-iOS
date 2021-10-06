//
//  ImageViewController.h
//  Adapted from Paul Hegarty's Shutterbug example.
//

#import <UIKit/UIKit.h>

#import "Spot.h"
#import "PhotoFetch.h"
#import "PhotoListTVC.h"

#import "Danaprajna.h"



//---------------------------------------- -o-
@interface ImageViewController : UIViewController

  // URL of a UIImage-compatible image (jpg, png, etc.)
  //
  @property  (strong, nonatomic)  NSURL      *imageURL;
  @property  (strong, nonatomic)  NSString   *titleText;

  @property  (weak, nonatomic)  IBOutlet  UIActivityIndicatorView  *activityIndicator;

  @property  (strong, nonatomic)  NSMutableDictionary  *photoEntry;

  @property  (nonatomic, getter=isPhotoEntryFromRecentsList)  BOOL  photoEntryFromRecentsList;

@end

