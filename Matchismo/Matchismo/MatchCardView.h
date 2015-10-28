//
// MatchCardView.h
//
// Adapted directly from P.Hegarty "PlayingCardView.m".
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <UIKit/UIKit.h>


@interface MatchCardView : UIView

  @property (nonatomic)                   NSUInteger     rank;
  @property (strong, nonatomic)           NSString      *suit;

  @property (nonatomic, getter=isFaceUp)      BOOL       faceUp;


  - (void)pinch:(UIPinchGestureRecognizer *)gesture;

@end

