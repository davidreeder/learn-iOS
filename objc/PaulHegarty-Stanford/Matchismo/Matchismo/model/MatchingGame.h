//
//  MatchingGame.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <Foundation/Foundation.h>

#import "Deck.h"

#import "Danaprajna.h"



//---------------------------------------------------- -o--
@interface MatchingGame : NSObject

  @property (strong, readonly, nonatomic)  NSMutableArray  *cards;  // of Card

  @property (readonly, nonatomic)          int              score;

  @property (strong, readonly, nonatomic)  id               action;
  @property (strong, readonly, nonatomic)  NSMutableArray  *actionHistory;

  @property (readonly, nonatomic)          NSUInteger       flipCost;
  @property (readonly, nonatomic)          NSUInteger       mismatchPenalty;

  @property (readonly, nonatomic)          Deck            *deck;


  // DESIGNATED INITIALIZER.
  //
  - (id)      initWithCardCount: (NSUInteger) cardCount
                      usingDeck: (Deck *)     deck
                       flipCost: (NSUInteger) flipCost
                mismatchPenalty: (NSUInteger) mismatchPenalty;

  - (Card *)     cardAtIndex:         (NSUInteger)index;
  - (NSArray *)  discardGroupAtIndex: (NSUInteger)index;

  - (NSUInteger) deckSize;
  - (NSUInteger) deckSizeOfDiscardPile;
  - (void)       userMessage: (NSString *)message;
  - (void)       updateScore: (int)score;
  - (Card *)     drawRandomCard;
  - (void)       addCardsToDiscardPile: (NSArray *)cardList;


@end // MatchingGame



//---------------------------------------------------- -o--
#define MATCHGAME_NUMCARDS_MAX          52
#define MATCHGAME_NUMCARDS_MIN          2
#define MATCHGAME_NUMCARDS_DEFAULT      22

