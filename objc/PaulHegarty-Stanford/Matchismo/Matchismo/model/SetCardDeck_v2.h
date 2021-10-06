//
// SetCardDeck_v2.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "Deck.h"
#import "SetCard_v2.h"

#import "Danaprajna.h"



//---------------------------------------------------- -o-
#undef debug
//#define debug           


@interface SetCardDeck_v2 : Deck

  @property (readonly, strong, nonatomic)  NSDictionary  *cardDict;


  // DESIGNATED INITIALIZER (for subclass)
  - (id) init;

  - (BOOL) findRandomMatch: (NSArray *) deck
                enableHint: (BOOL)      enableHint;

  - (NSArray *) findFirstMatch: (NSArray *) deck;

  - (void) clearHintedFlags: (NSArray *) deck;

@end // @interface SetCardDeck_v2 : Deck

