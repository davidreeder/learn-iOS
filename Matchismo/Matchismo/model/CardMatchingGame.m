//
//  CardMatchingGame.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "CardMatchingGame.h"



//---------------------------------------------------- -o-
@interface CardMatchingGame()

  @property (strong, readwrite, nonatomic)  NSMutableArray  *cards;  // of Card

  @property (readwrite, nonatomic)          int              score;

  @property (strong, readwrite, nonatomic)  id               action;
  @property (strong, readwrite, nonatomic)  NSMutableArray  *actionHistory;

@end // CardMatchingGame



//---------------------------------------------------- -o-
#define MATCH_BONUS             4



//---------------------------------------------------- -o-
@implementation CardMatchingGame

//
// methods
//

- (void) flipCardAtIndex:(NSUInteger)index
{
  Card *card = [self cardAtIndex:index];
  int   localscore = 0;
  

  // Clear action for this turn.
  //
  self.action = nil;


  if (!card.isUnplayable) {
    if (!card.isFaceUp) 
    {

      for (Card *otherCard in self.cards) {
        if (!otherCard.isUnplayable && otherCard.isFaceUp) 
        {
          int matchScore = [card match:@[otherCard]];

          if (matchScore) {
            otherCard.unplayable  = YES;
            card.unplayable       = YES;

            localscore            = matchScore * MATCH_BONUS;
            self.score           += localscore;

            self.action      
              = [NSString stringWithFormat:@"%@ matches %@ for %d points.", 
                  card.contents, otherCard.contents, localscore];

          } else {
            otherCard.faceUp      = NO;

            localscore            = self.mismatchPenalty;
            self.score           -= localscore;

            self.action      
              = [NSString stringWithFormat:
                  @"%@ and %@ do not match.  Penalty %d!", 
                    card.contents, otherCard.contents, localscore];
          }

          break;
        }
      } // endfor

      self.score -= self.flipCost;
    } // endif -- ! card.isFaceUp


    card.faceUp = !card.faceUp;

    if (! self.action) {
      self.action = [NSString stringWithFormat:@"%@ is flipped %@.", 
        card.contents, (card.faceUp ? @"up" : @"down")];
    }

  } // endif -- ! card.isUnplayable


} // flipCardAtIndex

@end // CardMatchingGame -- implementation

