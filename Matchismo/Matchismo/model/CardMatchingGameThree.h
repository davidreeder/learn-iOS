//
//  CardMatchingGameThree.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <Foundation/Foundation.h>

#import "Deck.h"
#import "SetCardDeck_v2.h"
#import "CardMatchingGame.h"
#import "UserMessage.h"

#import "Danaprajna.h"



//---------------------------------------------------- -o-
@interface CardMatchingGameThree : CardMatchingGame

  - (void) flipCardAtIndex:  (NSUInteger) index;

  - (void) userMessage:  (NSString *) message;


  // Methods to support SetCardDeck_v2.
  //
  - (BOOL)      findRandomMatchWithEnableHint: (BOOL)enableHint;
  - (NSArray *) findFirstMatch;
  - (void)      clearHintedFlags;

@end // CardMatchingGameThree

