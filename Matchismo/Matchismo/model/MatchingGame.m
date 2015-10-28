//
//  MatchingGame.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "MatchingGame.h"



//---------------------------------------------------- -o--
@interface MatchingGame()

  @property (strong, readwrite, nonatomic)  NSMutableArray  *cards;  // of Card

  @property (readwrite, nonatomic)          int              score;

  // The type of the action and history of actions (actionHistory) vary
  //   according to the type of card in the game.  
  // Normally action is represented as NSString.
  // In Set Game (v2), an action is represented by class object UserMessage
  //   which instructs UserMessageView how to display the message.
  // To maintain consistency of messages across games, UserMessage must be 
  //   considered whenever NSString assignments to action are updated.  XXX
  //
  @property (strong, readwrite, nonatomic)  id               action;
  @property (strong, readwrite, nonatomic)  NSMutableArray  *actionHistory;

  @property (readwrite, nonatomic)          NSUInteger       flipCost;
  @property (readwrite, nonatomic)          NSUInteger       mismatchPenalty;

  @property (readwrite, nonatomic)          Deck            *deck;

@end // MatchingGame()




//---------------------------------------------------- -o--
@implementation MatchingGame

//
// constructor
//

//------------------- -o-
// initWithCardCount:usingDeck
//
// DESIGNATED INITIALIZER.
//
// NB  Keep a pointer to deck for use in Set Game.
//
- (id) initWithCardCount: (NSUInteger)count  
               usingDeck: (Deck *)deck
                flipCost: (NSUInteger)flipCost
         mismatchPenalty: (NSUInteger)mismatchPenalty
{
  self = [super init];

  if (self) 
  {
    for (int i = 0; i < count; i++) 
    {
      Card *card = [deck drawRandomCard];
      if (!card) {
        self = nil;
        break;  // XXX 

      } else {
        self.cards[i] = card;
      }
    } // endfor

    self.flipCost         = flipCost;
    self.mismatchPenalty  = mismatchPenalty;

    self.deck             = deck;
  }

  return self;

} // initWithCardCount:usingDeck:



//---------------------------------------------------- -o--
// getters/setters
//

- (NSMutableArray *) cards
{
  if (!_cards)  { _cards = [[NSMutableArray alloc] init]; }
  return _cards;
}



//
- (NSMutableArray *) actionHistory
{
  if (!_actionHistory)  { _actionHistory = [[NSMutableArray alloc] init]; }
  return _actionHistory;
}


//
- (void) setAction: (id)currentAction
{
  if (currentAction) {
    [self.actionHistory addObject:currentAction];
  }
  _action = currentAction;
}




//---------------------------------------------------- -o--
// methods
//

//------------------- -o-
- (Card *) cardAtIndex:(NSUInteger)index
{
  return (index < [self.cards count]) ? self.cards[index] : nil;
}


//-------------------------- -o-
- (NSArray *) discardGroupAtIndex:(NSUInteger)index
{
  return (index < [self deckSizeOfDiscardPile]) ? [self.deck discardGroupAtIndex:index] : nil;
}


//------------------- -o-
// deckSize
//
// NB  Misnamed -- deckSize is the number of unplayed cards yet 
//     remaining in the deck.
//
- (NSUInteger) deckSize
{
  return [self.deck size];
}


//------------------- -o-
- (NSUInteger) deckSizeOfDiscardPile
{
  return [self.deck sizeOfDiscardPile];
}


//------------------- -o-
- (NSUInteger) cardDictSize 	// ABSTRACT
{
  return 0;
}


//------------------- -o-
- (void) userMessage: (NSString *)message
{
  self.action = message;
}


//------------------- -o-
- (void) updateScore: (int)score
{
  self.score += score;
}


//------------------- -o-
- (Card *) drawRandomCard
{
  return [self.deck drawRandomCard];
}


//------------------- -o-
- (void) addCardsToDiscardPile: (NSArray *)cardList
{
  [self.deck addCardsToDiscardPile:cardList];
}


@end // @implementation MatchingGame

