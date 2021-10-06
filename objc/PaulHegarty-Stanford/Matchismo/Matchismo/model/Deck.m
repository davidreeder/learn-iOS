//
// Deck.m
//
// A deck of cards.
//
// Cards can be in ONLY one of three places:
//   . in Deck::cards
//   . in Deck::discardPile
//   . or in the set of cards managed by the game (Match or Set)
//
// A Deck initializes itself (self.cards) with a full set of unique cards.
// Cards are randomly removed from the deck into the game with drawRandomCard.
// Cards are put back into the deck (self.discardPile) in groups by the game.
//
// The game is responsible for managing the integrity of the set of all possible
//   cards as they are taken from and returned to the Deck.
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "Deck.h" 



//---------------------------------------------------- -o-
@interface Deck()

  @property (strong, nonatomic)             NSMutableArray  *cards;        // of Card

  // discardPile is an array of arrays.
  //
  @property (strong, readwrite, nonatomic)  NSMutableArray  *discardPile;  // groups of Card

@end 




//---------------------------------------------------- -o-
@implementation Deck

//
// getters/setters
//

//------------------- -o-
- (NSMutableArray *) cards
{
  if (!_cards)  { _cards = [[NSMutableArray alloc] init]; }
  return _cards;
}


//------------------- -o-
- (NSMutableArray *) discardPile
{
  if (!_discardPile)  { _discardPile = [[NSMutableArray alloc] init]; }
  return _discardPile;
}




//---------------------------------------------------- -o-
// methods
//

//------------------- -o-
- (void) addCard:(Card *)card  atTop:(BOOL)atTop
{
  if (atTop) {
    [self.cards insertObject:card atIndex:0];

  } else {
    [self.cards addObject:card];
  }
}


//------------------- -o-
// addCardsToDiscardPile:
//
// Cards are optionally grouped by the calling environment as a means
// to preserve grouping choices made by the user.
//
- (void) addCardsToDiscardPile: (NSArray *)cardList
{
  [self.discardPile addObject:cardList];
}



//------------------- -o-
// drawRandomCard
//
- (Card *)drawRandomCard
{
  Card *randomCard = nil;

  if (self.cards.count) {
    unsigned index = arc4random() % self.cards.count;
    randomCard = self.cards[index];
    [self.cards removeObjectAtIndex:index];
  }

  return randomCard;
}


//------------------- -o-
- (NSUInteger) size 
{
  return [self.cards count];
}


//------------------- -o-
- (NSUInteger) sizeOfDiscardPile
{
  return [self.discardPile count];
}


//------------------- -o-
- (NSArray *) discardGroupAtIndex: (NSUInteger)index
{
  return self.discardPile[index];
}


@end // Deck -- implementation

