//
//  CardGameViewController.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <UIKit/UIKit.h>

#import "GameViewController.h"

#import "PlayingCardDeck.h"
#import "CardMatchingGame.h"
#import "CardMatchingGameThree.h"
#import "GameSettingsViewController.h"
#import "ScoreTuple.h"

#import "Danaprajna.h"



//---------------------------------------------------- -o-
//#define TWOCARD_MATCHGAME_ONLY           
  // Allows TWO-card match game only.  
  //   Makes THREE-card game inaccessible.



//--------------------------- -o-
#undef debug
//#define debug 

@interface CardGameViewController : GameViewController

#if !defined(TWOCARD_MATCHGAME_ONLY) 
  // segmentAction implements switch between 2- and 3-card match game.
  //
  - (IBAction)  segmentAction:  (UISegmentedControl *)  sender;
#endif

  - (void) updateUI;

@end

