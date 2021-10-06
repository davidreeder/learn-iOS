//
// PlayingCard.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "PlayingCard.h"




//---------------------------------------------------- -o--
@implementation PlayingCard

  @synthesize suit = _suit;     // because we provide both setter and getter



//---------------------------------------------------- -o--
#define PLAYINGCARD_SCORE_TWOMATCH_SUIT  1
#define PLAYINGCARD_SCORE_TWOMATCH_RANK  4
#define PLAYINGCARD_SCORE_THREEMATCH_SUIT  2
#define PLAYINGCARD_SCORE_THREEMATCH_RANK  8



//---------------------------------------------------- -o--
// class methods
//

+ (NSArray *) validSuits
{
  static NSArray  *validSuits = nil;

  if (!validSuits)  { validSuits = @[@"♠",@"♦",@"♥",@"♣"]; }
  return validSuits;
}


+ (NSArray *) rankStrings
{
  static NSArray  *rankStrings = nil;

  if (!rankStrings) 
  {
    rankStrings = 
      @[@"?", @"A", 
        @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", 
        @"J", @"Q", @"K"
      ];
  }

  return rankStrings;
}


+ (NSUInteger) maxRank
{
  return [self rankStrings].count - 1;
}



//---------------------------------------------------- -o--
// setter/getters
//

- (NSString *) contents
{
  NSArray *rankStrings = [[self class] rankStrings];
  return [rankStrings[self.rank] stringByAppendingString:self.suit];
}



//
- (NSString *) suit
{
  return _suit ? _suit : @"?";
}


- (void) setSuit: (NSString *) suit
{
  if ([[[self class] validSuits] containsObject:suit]) {
    _suit = suit;
  }
}



//
- (void) setRank: (NSUInteger) rank
{
  if (rank <= [[self class] maxRank]) {
    _rank = rank;
  }
}




//---------------------------------------------------- -o--
// methods
//

- (NSString *)description  
{ 
  return self.contents; 
}



//------------------- -o-
// match
//
// Simple matching rules: All cards must have the same rank
// or the same suit.
//
//
// ASSUME  THREE card match is not called with an array of 
//         less than two cards.
//
// XXX  PlayingCard is "overloaded" to accomdate two different games:
//      CardMatchingGame and CardMatchingGameThree.
//
- (int) match:(NSArray *)otherCards
{
  int score = 0;


  if (otherCards.count == 1)            // comparision of TWO cards
  {
    id otherCard = [otherCards lastObject];

    if ([otherCard isKindOfClass:[PlayingCard class]]) 
    {
      PlayingCard *otherPlayingCard = (PlayingCard *) otherCard;

      if ([otherPlayingCard.suit isEqualToString:self.suit]) {
        score = PLAYINGCARD_SCORE_TWOMATCH_SUIT;
      } else if (otherPlayingCard.rank == self.rank) {
        score = PLAYINGCARD_SCORE_TWOMATCH_RANK;
      }
    }

  } else if (otherCards.count == 2)     // comparision of THREE cards
  {
    id otherCard0 = [otherCards objectAtIndex:0];
    id otherCard1 = [otherCards objectAtIndex:1];

    if ([otherCard0 isKindOfClass:[PlayingCard class]]
         && [otherCard0 isKindOfClass:[PlayingCard class]])
    {
      PlayingCard *otherPlayingCard0 = (PlayingCard *) otherCard0;
      PlayingCard *otherPlayingCard1 = (PlayingCard *) otherCard1;

      if ([otherPlayingCard0.suit isEqualToString:self.suit]
            && [otherPlayingCard1.suit isEqualToString:self.suit]) {
        score = PLAYINGCARD_SCORE_THREEMATCH_SUIT;

      } else if ((otherPlayingCard0.rank == self.rank)
                    && (otherPlayingCard1.rank == self.rank)) {
        score = PLAYINGCARD_SCORE_THREEMATCH_RANK;
      }
    }
  }


  return score;

} // match


@end // PlayingCard -- implementation

