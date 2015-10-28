//
// SetCardDeck.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "Deck.h"
#import "SetCard.h"

#import "Danaprajna.h"



//---------------------------------------------------- -o-
#undef debug
//#define debug           

@interface SetCardDeck : Deck

  @property (readonly, strong, nonatomic)  NSDictionary  *cardDict;


  // DESIGNATED INITIALIZER (for subclass)
  - (id) init;

  + (NSAttributedString *)convertToAttributedString: (NSString *)cardMsg
                                           withDeck: (SetCardDeck *)deck;

@end // @interface SetCardDeck : Deck

