//
// SetCardView.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <UIKit/UIKit.h>

#import "SetCard_v2.h"

#import "Danaprajna.h"



//--------------------------------------------------------------- -o-
#undef debug
//#define debug                         

@interface SetCardView : UIView

  @property (nonatomic)  NSUInteger  count;
  @property (nonatomic)  SCShape     shape;  
  @property (nonatomic)  SCColor     color; 
  @property (nonatomic)  SCShade     shade;

  @property (nonatomic, getter=isFaceUp)  BOOL  faceUp;
  @property (nonatomic, getter=isHinted)  BOOL  hinted;


  // g*Magic numbers are established by trial-and-error in the
  //   largest drawing of the card.
  // The result is saved as an image which can be scaled to other
  //   size CGRects.
  //
  @property  (nonatomic)  CGFloat  gWidthMagic;
  @property  (nonatomic)  CGFloat  gHeightMagic;

  @property  (nonatomic)  CGFloat  gWidthOffsetMagic;
  @property  (nonatomic)  CGFloat  gHeightOffsetMagic;


  //
  @property  (nonatomic)  UIImage *setCardImage;  
      // Rendered image of this card

  
  //
  // DESIGNATED INITIALIZER
  - (id)initWithFrame: (CGRect)     frame;

  - (id)initWithFrame: (CGRect)     frame
                count: (NSUInteger) count
                shape: (SCShape)    shape
                color: (SCColor)    color
                shade: (SCShade)    shade;

  //
  - (void) generateCardImage;

  - (void) borderUnselected;
  - (void) borderSelected;
  - (void) borderHint;


  //
  + (UIImage *) imageFromSetCard: (SetCard_v2 *)setcard  
                          inRect: (CGRect) rect;
  
  + (CGFloat) sizeRatio;

@end



//--------------------------------------------------------------- -o-
#define SETCARD_STANDARD_WIDTH   66.0
#define SETCARD_STANDARD_HEIGHT  87.0

#define SETCARD_SIZE_RATIO  (SETCARD_STANDARD_WIDTH / SETCARD_STANDARD_HEIGHT)




