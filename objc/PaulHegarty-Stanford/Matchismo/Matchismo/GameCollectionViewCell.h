//
// GameCollectionViewCell.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <UIKit/UIKit.h>

#import "MatchCardView.h"

#import "SetCardView.h"
#import "DiscardGroupingView.h"



//--------------------------------------------------------- -o-
@interface GameCollectionViewCell : UICollectionViewCell

  @property (weak, nonatomic)  IBOutlet  MatchCardView  *matchCardView;

  @property (weak, nonatomic)  IBOutlet  SetCardView    *setCardView;
  @property (weak, nonatomic)  IBOutlet  DiscardGroupingView 
                                                        *setCardDiscardGroupingView;
@end

