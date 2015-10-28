//
//  CardMatchingGame.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <Foundation/Foundation.h>

#import "Deck.h"
#import "MatchingGame.h"

#import "Danaprajna.h"



//---------------------------------------------------- -o-
@interface CardMatchingGame : MatchingGame

  @property (strong, readonly, nonatomic)  NSMutableArray  *cards;  // of Card

  @property (readonly, nonatomic)          int              score;


  - (void)    flipCardAtIndex:(NSUInteger)index;

@end // CardMatchingGame

