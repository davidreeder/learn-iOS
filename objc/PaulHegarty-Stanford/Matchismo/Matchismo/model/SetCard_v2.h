//
// SetCard_v2.h
//
// Rules for Set taken from https://en.wikipedia.org/wiki/Set_(game) .
//
// Each SetCard_v2 may have between one and three shapes, all with the same
// three characteristics of shape, color and shade.  
//
// content (from Card) contains a string concatenating symbols for each
// characteristic -- it does not rely on NSAttributedString.
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "SetCard_universal.h"
#import "Card.h"

#import "Danaprajna.h"



//---------------------------------------------------- -o--
@interface SetCard_v2 : Card

  @property (readonly, nonatomic)  NSUInteger  count;
  @property (readonly, nonatomic)  SCShape     shape;  
  @property (readonly, nonatomic)  SCColor     color; 
  @property (readonly, nonatomic)  SCShade     shade;

  @property (nonatomic, getter=isHinted) BOOL  hinted;
      // Flag to indicate whether this card has been grouped with 
      //   others to display a match hint in UICollectionView.


  // DESIGNATED INITIALIZER.
  - (id) initWithShape:(SCShape)     shape 
                 color:(SCColor)     color 
                 shade:(SCShade)     shade
                 count:(NSUInteger)  count;

  - (BOOL)matchWithCard1:(SetCard_v2 *)card1 andCard2:(SetCard_v2 *)card2;


@end // @interface SetCard_v2 : Card



//---------------------------------------------------- -o--
#define SETCARD_FONT_SIZE       18
#define SETCARD_STROKE_WIDTH    -8
#define SETCARD_SHADE_FRACTION  0.2

#define SETCARD_DESCRIPTION_LENGTH  4   // Cf. contents method.

#define SETCARD_SCORE_MATCH  10

