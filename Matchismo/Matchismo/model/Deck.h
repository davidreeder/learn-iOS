//
// Deck.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <Foundation/Foundation.h>

#import "Card.h"
#import "Danaprajna.h"



//---------------------------------------------------- -o-
@interface Deck : NSObject

  @property (strong, readonly, nonatomic)  NSMutableArray  *discardPile;  // groups of Card


  - (void)   addCard:(Card *)card  atTop:(BOOL)atTop;
  - (void)   addCardsToDiscardPile:(NSArray *)cardList;

  - (Card *) drawRandomCard;

  - (NSUInteger)  size;
  - (NSUInteger)  sizeOfDiscardPile;

  - (NSArray *)   discardGroupAtIndex: (NSUInteger)index;

@end // Deck

