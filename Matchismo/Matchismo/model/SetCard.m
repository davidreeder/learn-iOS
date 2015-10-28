//
// SetCard.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "SetCard.h"



//---------------------------------------------------- -o--
@interface SetCard()

  @property (readwrite, nonatomic)  NSUInteger  count;
  @property (readwrite, nonatomic)  SCShape     shape;  
  @property (readwrite, nonatomic)  SCColor     color; 
  @property (readwrite, nonatomic)  SCShade     shade;

@end




//---------------------------------------------------- -o--
@implementation SetCard

//
// class methods
//

//------------------- -o-
// validShapes
//
// NB  Order of shapes returned must match indices of SCShape enum.
//
+ (NSArray *) validShapes
{
  static NSArray  *validShapes = nil;

  if (!validShapes)  { validShapes = @[@"■", @"▼", @"●"]; }
  return validShapes;
}



//---------------------------------------------------- -o-
// constructors
//

//------------------- -o-
// DESIGNATED INITIALIZER.
//
- (id) initWithShape:(SCShape)     shape 
               color:(SCColor)     color 
               shade:(SCShade)     shade
               count:(NSUInteger)  count
{
  self = [super init];

  if (self) {
    self.shape = shape;
    self.color = color;
    self.shade = shade;
    self.count = count;
  }

  return self;
}



//---------------------------------------------------- -o-
// setter/getters
//

//------------------- -o-
// contents
//
// "ASCII" only version of SetCard contents.  (ie, no NSAttributedStrings.)
//
// NB  Length is always four characters.
//
- (NSString *) contents
{
  NSString *str;

  str = [NSString stringWithFormat:@"%d%@%@%@",
    self.count, 
    [[[self class] validShapes] objectAtIndex:[@(self.shape) unsignedIntValue]],
    (self.color == SCColorOne) ? @"R"
       : ((self.color == SCColorThree) ? @"B" : @"G"),
    (self.shade == SCShadeFull) ? @"f"
       : ((self.shade == SCShadePartial) ? @"p" : @"c")
  ];


  return str;
}



//------------------- -o-
- (void) setCount:(NSUInteger)count
{
  if ((count >= 1) && (count <= SETCARD_COUNT_MAX))  { _count = count; }
}




//---------------------------------------------------- -o-
// methods
//

//------------------- -o-
- (NSString *)description  
{ 
  return self.contents; 
}



//------------------- -o-
// descriptionWithAttributedString
//
// RETURNS: NSAttributedString of count shapes with proper color and 
//          shade for this SetCard.
//
// XXXQ  Should this method be given elsewhere as a UI category?
//
- (NSAttributedString *)descriptionWithAttributedString
{
  UIColor  *colorValue = (self.color == SCColorOne) ? [UIColor redColor]
                           : ((self.color == SCColorThree) 
                             ? [UIColor blueColor] : [UIColor greenColor]);
  double  shadeValue = 
            (self.shade == SCShadeFull) ? 1.0 
              : ((self.shade == SCShadePartial) ? SETCARD_SHADE_FRACTION : 0.0);

  NSDictionary  *descAttrs = @{
    NSFontAttributeName         : [UIFont systemFontOfSize:SETCARD_FONT_SIZE],
    NSStrokeWidthAttributeName  : @(SETCARD_STROKE_WIDTH),
    NSStrokeColorAttributeName  : colorValue,
    NSForegroundColorAttributeName 
                          : [colorValue colorWithAlphaComponent:shadeValue]
                              };


  // Build NSString of shapes.
  // Convert to attributed string.
  //
  NSString  *foundation = @"";

  for (int i = 0; i < self.count; i++) {
    foundation = [foundation stringByAppendingString:
                   [[[self class] validShapes] objectAtIndex:self.shape]];
  }

  NSAttributedString  *descWithAttrs = 
    [[NSAttributedString alloc] initWithString:foundation attributes:descAttrs];


  return descWithAttrs;

} // descriptionWithAttributedString



//------------------- -o-
- (BOOL)matchWithCard1:(SetCard *)card1 andCard2:(SetCard *)card2
{
  if ( ((self.count == card1.count) && (self.count == card2.count))
         || ( (self.count != card1.count) && (self.count != card2.count)
            && (card1.count != card2.count)) )
  {
    if ( ((self.shape == card1.shape) && (self.shape == card2.shape))
           || ( (self.shape != card1.shape) && (self.shape != card2.shape)
              && (card1.shape != card2.shape)) )
    {
      if ( ((self.color == card1.color) && (self.color == card2.color))
             || ( (self.color != card1.color) && (self.color != card2.color)
                && (card1.color != card2.color)) )
      {
        if ( ((self.shade == card1.shade) && (self.shade == card2.shade))
               || ( (self.shade != card1.shade) && (self.shade != card2.shade)
                  && (card1.shade != card2.shade)) )
        {
          return true;

        } // endif -- shade
      } // endif -- color
    } // endif -- shape
  } // endif -- count


  return false;

} // matchWithCard1:andCard2:



//------------------- -o-
- (int) match:(NSArray *)otherCards
{
  int score = 0;


  if (otherCards.count == 2)     // comparision of THREE cards
  {
    id otherCard0 = [otherCards objectAtIndex:0];
    id otherCard1 = [otherCards objectAtIndex:1];

    if ([otherCard0 isKindOfClass:[SetCard class]]
         && [otherCard0 isKindOfClass:[SetCard class]])
    {
      SetCard *otherSetCard0 = (SetCard *) otherCard0;
      SetCard *otherSetCard1 = (SetCard *) otherCard1;

      if ([self matchWithCard1:otherSetCard0 andCard2:otherSetCard1])
      {
        score = SETCARD_SCORE_MATCH;
      }

    } // endif -- isKindOfClass
  }


  return score;

} // match


@end // @implementation SetCard

