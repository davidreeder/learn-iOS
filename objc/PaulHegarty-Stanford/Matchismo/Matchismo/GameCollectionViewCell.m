//
// GameCollectionViewCell.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "GameCollectionViewCell.h"



@implementation GameCollectionViewCell

//-------------------------- -o-
- (void) setMatchCardView:(MatchCardView *)matchCardView
{
  _matchCardView = matchCardView;
  [_matchCardView addGestureRecognizer:
    [[UIPinchGestureRecognizer alloc] initWithTarget: _matchCardView 
                                              action: @selector(pinch:)]];
}

@end

