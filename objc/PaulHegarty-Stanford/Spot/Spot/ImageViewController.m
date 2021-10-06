//
//  ImageViewController.m
//  Adapted from Paul Hegarty's Shutterbug example.
//

#import "ImageViewController.h"



//--------------------------------------------- -o--
@interface ImageViewController() <UIScrollViewDelegate>

  @property (weak, nonatomic)   IBOutlet  UIScrollView     *scrollView;
  @property (strong, nonatomic)           UIImageView      *imageView;

  @property (weak, nonatomic)   IBOutlet  UIToolbar        *toolbarOutlet;
  @property (weak, nonatomic)   IBOutlet  UIBarButtonItem  *toolbarTitleOutlet;
  @property (weak, nonatomic)   IBOutlet  UINavigationItem *navigationItemOutlet;

  @property (weak, nonatomic)             UIBarButtonItem  *splitViewBarButtonItem;


  @property (nonatomic, getter=isViewDestroyed)  BOOL  viewDestroyed;


  - (void) resetImage;
  - (void) initialZoomSetting;
 
@end



//--------------------------------------------- -o--
@implementation ImageViewController

#pragma mark - Constructors.

//------------ -o-
// viewDidLoad
//
// NB  Reset image in case URL is set before outlets (e.g. self.scrollView) is set.
//     Eg: When self.imageURL is set before segue is executed.
//
- (void) viewDidLoad
{
  [super viewDidLoad];

  [self.scrollView addSubview:self.imageView];
  self.scrollView.minimumZoomScale = 0.2;
  self.scrollView.maximumZoomScale = 5.0;
  self.scrollView.delegate = self;

  [self resetImage];

  [self assignToolbarTitle];

  self.viewDestroyed = NO;

  // iPhone -- Hide toolbar when navigating from Recents.
  //
  [UIView animateWithDuration: PF_TABBAR_FADETIME
                   animations: ^{
                     [self.navigationController setToolbarHidden:YES animated:YES];
                     self.navigationController.toolbar.alpha = 0;
                   } ];

} // viewDidLoad



//------------ -o-
// viewDidLayoutSubviews
//
- (void) viewDidLayoutSubviews
{
  static  BOOL  firstTimeInLayoutSubviews = YES;

  [super viewDidLayoutSubviews];


  // Preserve image zoom and position between device rotations.
  //
  if (firstTimeInLayoutSubviews) {
    [self initialZoomSetting];
    firstTimeInLayoutSubviews = NO;
  }

  // NB  Needed to redraw button in any replaced detailVC.
  //
  [self setSplitViewBarButtonItem:self.splitViewBarButtonItem];


  // XXX  Something triggers navigation toolbar to return on iPhone?
  //
  [UIView animateWithDuration: PF_TABBAR_FADETIME
                   animations: ^{
                     [self.navigationController setToolbarHidden:YES animated:YES];
                     self.navigationController.toolbar.alpha = 0;
                   } ];
}



//------------ -o-
// viewDidDisappear:
//
- (void) viewDidDisappear: (BOOL)animated
{
  [super viewDidDisappear:animated];
    
  self.viewDestroyed = YES;
}



//--------------------------------------------- -o--
#pragma mark - Getters/setters.

//------------ -o-
- (void) setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}


//------------ -o-
- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}



//------------ -o-
- (void) setTitleText: (NSString *)title
{
  _titleText = title;
  [self assignToolbarTitle];
}


//------------ -o-
- (void) assignToolbarTitle
{
  self.toolbarTitleOutlet.title = self.titleText;       // iPad
  self.navigationItemOutlet.title = self.titleText;     // iPhone
}



//------------------ -o-
// setSplitViewBarButtonItem:
//
// Remove and replace existing splitViewBarButton, may be nil.
//
// Suggested in Paul Hegarty lecture slides.
//
- (void) setSplitViewBarButtonItem: (UIBarButtonItem *)barButtonItem 
{
  NSMutableArray  *toolbarItems = [self.toolbarOutlet.items mutableCopy];


  // Remove current bar button and replace with the new one, if any.
  //
  if (_splitViewBarButtonItem) {
    [toolbarItems removeObject:_splitViewBarButtonItem];
  }

  if (barButtonItem) {
    [toolbarItems insertObject:barButtonItem atIndex:0];
  }


  // Remember choice, update toolbar.
  //
  _splitViewBarButtonItem = barButtonItem;
  self.toolbarOutlet.items = toolbarItems;

} // setSplitViewBarButtonItem:




//--------------------------------------------- -o--
#pragma mark - UIScrollView delegate.

//------------ -o-
- (UIView *) viewForZoomingInScrollView: (UIScrollView *)scrollView
{
    return self.imageView;
}




//--------------------------------------------- -o--
#pragma mark - Methods.

//------------ -o-
// resetImage
//
// Fetch data from URL, via network or cache.
// Add new images to recents list.
// Zoom image to form factor of UIImage window.
//
- (void) resetImage
{
  if (self.scrollView) 
  {
    self.scrollView.backgroundColor  = [UIColor blackColor];

    self.scrollView.contentSize      = CGSizeZero;
    self.imageView.image             = nil;
    

    // iPad opens ImageViewController before selecting an image...
    //
    if (!self.imageURL)  { return; }


    //
    [self.activityIndicator startAnimating];

    dispatch_async(DP_ASYNC_QUEUE(@"for fetching images"), 
    ^{
      NSData   *imageData;
      NSURL    *cachedPhotoURL;
      NSError  *error = nil;


      cachedPhotoURL = [[PhotoFetch photoCache] cachedFileURL:PF_PHOTOENTRY_FILENAME(self.photoEntry) ];

      if (cachedPhotoURL) {
        imageData = [[NSData alloc] initWithContentsOfURL:cachedPhotoURL options:0 error:&error];

      } else {
        [Zed networkIndicatorEnable:YES];
        imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL options:0 error:&error];
        [Zed networkIndicatorEnable:NO];
      }


      // NB  Flickr intecepts bad URLs and returns an image containing and err message.
      //
      if (error) 
      {
        DP_LOG_NSERROR(error);

        dispatch_async(dispatch_get_main_queue(), 
        ^{
          if (!self.isViewDestroyed) 
          {
            NSURL  *imageSourceURL = cachedPhotoURL ? cachedPhotoURL : self.imageURL;

            UIAlertView  *anAlert = [[UIAlertView alloc] initWithTitle: @"Image Download Failed."
                                                               message: DP_STRWFMT(@"Could not resolve URL: %@ .", imageSourceURL)
                                                              delegate: nil
                                                     cancelButtonTitle: nil
                                                     otherButtonTitles: @"OK", nil ];
            [anAlert show];
          }

          [self.activityIndicator stopAnimating];
        });

        return;
      }

      UIImage  *image = [[UIImage alloc] initWithData:imageData];


      //
      dispatch_async(dispatch_get_main_queue(), 
      ^{
        if (! self.isViewDestroyed)
        {       
          if (self.photoEntry)
          {
            dispatch_async([PhotoFetch photoCacheQueue],
            ^{
              if (! self.isPhotoEntryFromRecentsList) {
                [PhotoFetch addToRecentsList:self.photoEntry];
              }

              [[PhotoFetch photoCache] saveFile: PF_PHOTOENTRY_FILENAME(self.photoEntry)
                                       withData: imageData ];
            });
          }

          if (image) {      
            self.scrollView.zoomScale   = 1.0;
            self.scrollView.contentSize = image.size;
            self.imageView.image        = image;
            self.imageView.frame        = CGRectMake(0, 0, image.size.width, image.size.height);
          }

          [self initialZoomSetting];

        } // endif -- ! self.isViewDestroyed

        [self.activityIndicator stopAnimating];

      }); // main thread queue
    }); // fetch thread queue

  } // endif -- self.scrollView

} // resetImage



//------------ -o-
// initialZoomSetting
//
// Fill scroll view with image, but show as much if image as possible.
//   If ratio of image (W/H) is less than ratio of scrollView (W/H),
//   zoom to width of image, otherwise zoom to height of image.
//
- (void) initialZoomSetting
{
  CGFloat  imageWidth   = self.imageView.image.size.width,
           imageHeight  = self.imageView.image.size.height,
           svWidth      = self.scrollView.bounds.size.width,
           svHeight     = self.scrollView.bounds.size.height,
           edgeRatio    = 1.0;


  CGFloat  imageRatio       = imageWidth/imageHeight,  // <1 for tall; >1 for squat; 1 for square.
           scrollviewRatio  = svWidth/svHeight;

  CGRect  zoomRect = CGRectZero;


  if (1 == imageRatio) {
    if (svWidth < svHeight) {
      edgeRatio = svWidth / imageWidth;
      zoomRect = CGRectMake(0, 0, svWidth, imageHeight);

    } else {
      edgeRatio = svHeight / imageHeight;
      zoomRect = CGRectMake(0, 0, imageWidth, svHeight);
    }

  } else {
    if (imageRatio < scrollviewRatio) {
      zoomRect = CGRectMake(0, 0, imageWidth, svHeight);

    } else {
      if (svHeight > imageHeight) {
	edgeRatio = imageHeight/svHeight;
      }
      zoomRect = CGRectMake(0, 0, svWidth * edgeRatio, imageHeight * edgeRatio);
    }
  }


  [self.scrollView zoomToRect:zoomRect animated:NO];

} // initialZoomSetting


@end

