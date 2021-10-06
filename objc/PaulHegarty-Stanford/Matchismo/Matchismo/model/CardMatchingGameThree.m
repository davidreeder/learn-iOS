//
//  CardMatchingGameThree.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "CardMatchingGameThree.h"



//---------------------------------------------------- -o--
@interface CardMatchingGameThree()

  @property (strong, readwrite, nonatomic)  NSMutableArray  *cards;  // of Card

  @property (readwrite, nonatomic)          int              score;

  @property (strong, readwrite, nonatomic)  id               action;
  @property (strong, readwrite, nonatomic)  NSMutableArray  *actionHistory;

@end // CardMatchingGameThree



//---------------------------------------------------- -o--
#define MATCH_BONUS             4



//---------------------------------------------------- -o--
@implementation CardMatchingGameThree

//
// methods
//

//--------------------------- -o-
// flipCardAtIndex:
//
// Adapted to post both NSString and UserMessage objects to the 
// user post window.  UserMessage is used when card is of type 
// SetCard_v2.  (Always ASSUME all cards are of the same type.)
//
- (void) flipCardAtIndex:(NSUInteger)index
{
  Card      *card        = [self cardAtIndex:index],
            *otherCard1  = nil, 
            *otherCard2  = nil;

  int        localscore = 0;
  

  // Clear action for this turn.
  //
  self.action = nil;


  if (!card.isUnplayable) {
    if (!card.isFaceUp) 
    {

      // Find two elligible cards.
      // TBD  Means to sort cards in order of selection: monotonic counter?
      //
      for (Card *otherCard in self.cards) {
        if (!otherCard.isUnplayable && otherCard.isFaceUp) 
        {
          if (! otherCard1) {
            otherCard1 = otherCard;
          } else if (! otherCard2) {
            otherCard2 = otherCard;
          } else {
            break;
          }
        }
      }

      if (otherCard1 && otherCard2) 
      {
        int matchScore = [card match:@[ otherCard1, otherCard2 ]];

        if (matchScore) {
          otherCard1.unplayable  = YES;
          otherCard2.unplayable  = YES;
          card.unplayable        = YES;

          localscore             = matchScore * MATCH_BONUS;
          self.score            += localscore;

          if ([card isKindOfClass:[SetCard_v2 class]])
	  {
	    self.action = 
	      [[UserMessage alloc] initWithCards: @[otherCard1, otherCard2, card]
	                                 isMatch: YES
				       andPoints: localscore ];

	  } else {
	    self.action = [NSString stringWithFormat:
	      @"%@, %@ and %@ match for %d points.", 
		otherCard1.contents, otherCard2.contents, card.contents, 
		  localscore];
	  }

        } else {
          otherCard1.faceUp  = NO;
          otherCard2.faceUp  = NO;

          localscore         = self.mismatchPenalty;
          self.score        -= localscore;

          if ([card isKindOfClass:[SetCard_v2 class]])
	  {
	    self.action = 
	      [[UserMessage alloc] initWithCards: @[otherCard1, otherCard2, card]
	                                 isMatch: NO
				       andPoints: localscore ];

	  } else {
	    self.action = [NSString stringWithFormat:
	      @"%@, %@ and %@ do not all match.  Penalty %d!", 
		otherCard1.contents, otherCard2.contents, card.contents, 
		  localscore];
	  }
        }
      }

      self.score -= self.flipCost;
    }


    card.faceUp = !card.faceUp;

    if (! self.action) {
      if ([card isKindOfClass:[SetCard_v2 class]])
      {
	self.action = 
	  [[UserMessage alloc] initWithCards: @[card]
				   isFlipped: card.faceUp ];

      } else {
	self.action = [NSString stringWithFormat:@"%@ is flipped %@.", 
	  card.contents, (card.faceUp ? @"up" : @"down")];
      }
    }

  } // endif

} // flipCardAtIndex



//------------------- -o-
// userMessage: 
//
// Subclassed to create UserMessage.
//
- (void) userMessage: (NSString *)message
{
  self.action = [[UserMessage alloc] initWithMessage:message];
}



//---------------------------------------------------- -o--
// Methods to support SetCardDeck_v2.
//

//--------------------------- -o-
- (BOOL) findRandomMatchWithEnableHint: (BOOL)enableHint
{
  if (! [self.deck isKindOfClass:[SetCardDeck_v2 class]]) {
    [Log warnMsg:
      [NSString stringWithFormat:@"%@::clearHintedFlags: -- %@",
        @"Only supported with deck of type SetCardDeck_v2!", 
          [self class]] ];
    return NO; 
  }

  return [(SetCardDeck_v2 *)self.deck findRandomMatch: self.cards
                                           enableHint: enableHint ];
} 


//--------------------------- -o-
- (NSArray *) findFirstMatch
{
  if (! [self.deck isKindOfClass:[SetCardDeck_v2 class]]) {
    [Log warnMsg:
      [NSString stringWithFormat:@"%@::clearHintedFlags: -- %@",
        @"Only supported with deck of type SetCardDeck_v2!", 
          [self class]] ];
    return nil; 
  }

  return [(SetCardDeck_v2 *)self.deck findFirstMatch:self.cards];
}


//--------------------------- -o-
// clearHintedFlags
//
- (void) clearHintedFlags
{
  if (! [self.deck isKindOfClass:[SetCardDeck_v2 class]]) {
    [Log warnMsg:
      [NSString stringWithFormat:@"%@::clearHintedFlags: -- %@",
        @"Only supported with deck of type SetCardDeck_v2!", 
          [self class]] ];
    return; 
  }

  [(SetCardDeck_v2 *)self.deck clearHintedFlags:self.cards];
}


@end // CardMatchingGameThree -- implementation

