//
//  SetGameViewController.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <UIKit/UIKit.h>

#import "SetCardDeck.h"
#import "CardMatchingGameThree.h"

#import "GameViewController.h"
#import "GameSettingsViewController.h"

#import "ScoreTuple.h"



//---------------------------------------------------- -o-
#undef debug 			  
//#define debug             

@interface SetGameViewController : GameViewController

  - (void) updateUI;

@end

