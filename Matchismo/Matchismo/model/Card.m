//
// Card.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "Card.h"



//---------------------------------------------------- -o-
@interface Card()
@end



//---------------------------------------------------- -o-
@implementation Card


//------------------- -o-
// match
//
// Effectively: an abstract method.
//

- (int) match: (NSArray *)otherCards
{
  int score = 0;

  for (Card *card in otherCards) {
    if ([card.contents isEqualToString:self.contents]) {
      score = 1;
      break;
    }
  }

  return score;

} // match


@end // @implementation Card

