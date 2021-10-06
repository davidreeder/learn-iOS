//
// SetCardDeck_v2.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "SetCardDeck_v2.h"



//---------------------------------------------------- -o-
@interface SetCardDeck_v2()

  @property (readwrite, strong, nonatomic)  NSDictionary  *cardDict;

@end



//---------------------------------------------------- -o-
@implementation SetCardDeck_v2

//
// constructors
//

//------------------- -o-
// DESIGNATED INITIALIZER (for subclass)
//
- (id) init
{
  self = [super init];

  if (self) 
  {
    NSMutableDictionary *dictionaryOfCards = [[NSMutableDictionary alloc] init];

    for (int shape = SCShapeOne; shape < SCShapeMax; shape++) {
      for (int color = SCColorOne; color < SCColorMax; color++) {
        for (int shade = SCShadeFull; shade < SCShadeMax; shade++) {
          for (int i = 1; i <= SETCARD_COUNT_MAX; i++) 
          {
            SetCard_v2 *card = [[SetCard_v2 alloc] initWithShape: shape
                                                           color: color
                                                           shade: shade
                                                           count: i ];
            [self addCard:card atTop:YES];
            [dictionaryOfCards setObject:card forKey:[card description]];
          }
        }
      }
    }

    self.cardDict = dictionaryOfCards;  // XXX  coerce to immutable NSDictionary


#ifdef debug
  [Dump lp: [NSString stringWithFormat:@"ALL CARDS (%d)", [self.cardDict count]]
      objs: [[self.cardDict allKeys] sortedArrayUsingComparator:DP_BLOCK_CMPSTR] ];
#endif

  } // endif


  return self;

} // init




//---------------------------------------------------- -o-
// methods
//

//------------------- -o-
// findRandomMatch: 
//
// Find first match on a shuffled copy of the active deck. 
// If enabledHint is YES, then set hinted flag on only the
//   three matched cards.  Any previous hinted flags are 
//   cleared only if the expectation is to replace them.
//
// ASSUME  If first item in deck is SetCard_v2, then all 
//         objects are SetCard_v2. XXX
//
// NB  Both shuffleArray: and findFirstMatch: return copies 
//       of their input array.
//
- (BOOL) findRandomMatch: (NSArray *) deck
              enableHint: (BOOL)      enableHint
{
  if ([deck count] < 3)  { return NO; }         // Bad deck -- no match.

  if (! [deck[0] isKindOfClass:[SetCard_v2 class]]) { 
    [Log warnMsg:
      [NSString stringWithFormat:@"%@::findRandomMatch:enableHint: -- %@",
        @"Input array does not contain elements of class SetCard_v2!", 
          [self class]] ];
    return NO;                                  // Bad deck -- no match.
  } 

  if (enableHint) {
    [self clearHintedFlags:deck];
  }

  NSArray *matchedCards = [self findFirstMatch:[Zed shuffleArray:[deck copy]]];
    // NB  deck container must be copied to avoid reshuffling in the view! 

  if (! matchedCards)  { return NO; }           // No match.

  if (enableHint) {
    for (SetCard_v2 *card in matchedCards) {
      card.hinted = YES;
    }
  }

  return YES;                                   // Found match.

} // findRandomMatch:enableHint: 



//------------------- -o-
// findFirstMatch: 
//
// Given an array of SetCard_v2, find and return the first match.
//
// Do this by removing the first card from the deck.  Then iterate through
// deck comparing the removed card, with the indexed card, with every card, 
// in turn, past the indexed card.
//
// RETURN: Array of three cards that match  -OR-  nil.
//
- (NSArray *) findFirstMatch: (NSArray *) deck
{
  NSMutableArray  *mutableDeck = [deck mutableCopy];
  Card            *card1, *card2, *card3;

  while (YES) 
  {
    if ([mutableDeck count] < 3)  { return nil; }    // No match found.

    card1 = (Card *) mutableDeck[0];
    [mutableDeck removeObjectAtIndex:0];

    for (int secondIndex = 0; secondIndex < [mutableDeck count]; secondIndex++)
    {
      card2 = (Card *) mutableDeck[secondIndex];
      for (int thirdIndex = secondIndex+1; thirdIndex < [mutableDeck count]; thirdIndex++)
      {
        card3 = (Card *) mutableDeck[thirdIndex];
        if ([card1 match:@[ card2, card3 ]] > 0)     // First match found.
        {
          return @[card1, card2, card3];
        }
      }
    } 

  } // endwhile

} // findFirstMatch: 



//------------------- -o-
// clearHintedFlags:
//
// ASSUME  If first item in deck is SetCard_v2, then all 
//         objects are SetCard_v2. XXX
//
- (void) clearHintedFlags: (NSArray *) deck
{
  if (! [deck[0] isKindOfClass:[SetCard_v2 class]]) {
    [Log warnMsg:
      [NSString stringWithFormat:@"%@::clearHintedFlags: -- %@",
        @"Input array does not contain elements of class SetCard_v2!", 
          [self class]] ];
    return; 
  }

  for (id item in deck)
  {
    ((SetCard_v2 *)item).hinted = NO;
  }
}


@end // @implementation SetCardDeck_v2

