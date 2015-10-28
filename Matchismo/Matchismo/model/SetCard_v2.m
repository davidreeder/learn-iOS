//
// SetCard_v2.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "SetCard_v2.h"



//---------------------------------------------------- -o--
@interface SetCard_v2()

  @property (readwrite, nonatomic)  NSUInteger  count;
  @property (readwrite, nonatomic)  SCShape     shape;  
  @property (readwrite, nonatomic)  SCColor     color; 
  @property (readwrite, nonatomic)  SCShade     shade;

@end




//---------------------------------------------------- -o--
@implementation SetCard_v2

#pragma mark - Class Methods 


//------------------- -o-
// validShapes
//
// NB  Order of shapes returned must match indices of SCShape enum.
//
+ (NSArray *) validShapes
{
  static NSArray  *validShapes = nil;

  if (!validShapes)  { validShapes = @[@"S", @"D", @"T"]; }
  return validShapes;
}



//---------------------------------------------------- -o--
#pragma mark - Constructors 

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



//---------------------------------------------------- -o--
#pragma mark - Getters/Setters 


//------------------- -o-
// contents
//
// "ASCII" only version of SetCard_v2 contents.  (ie, no NSAttributedStrings.)
//
- (NSString *) contents
{
  NSString *str;

  str = [NSString stringWithFormat:@" %d%@.%@%@",
    self.count,
    [[[self class] validShapes] objectAtIndex:self.shape],
    (self.color == SCColorOne) ? @"G"
       : ((self.color == SCColorTwo) ? @"P" : @"R"),
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



//---------------------------------------------------- -o--
#pragma mark - Comparators 

//-------------------------------------- -o-
- (NSComparisonResult) compare: (SetCard_v2 *) otherCard
{
  return [self.description compare:otherCard.description]; 
}




//---------------------------------------------------- -o--
#pragma mark - Overrides 

//------------------- -o-
- (NSString *)description  
{ 
  return self.contents; 
}



//---------------------------------------------------- -o--
#pragma mark - Methods 

//------------------- -o-
- (BOOL)matchWithCard1:(SetCard_v2 *)card1 andCard2:(SetCard_v2 *)card2
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

    if ([otherCard0 isKindOfClass:[SetCard_v2 class]]
         && [otherCard0 isKindOfClass:[SetCard_v2 class]])
    {
      SetCard_v2 *otherSetCard_v20 = (SetCard_v2 *) otherCard0;
      SetCard_v2 *otherSetCard_v21 = (SetCard_v2 *) otherCard1;

      if ([self matchWithCard1:otherSetCard_v20 andCard2:otherSetCard_v21])
      {
        score = SETCARD_SCORE_MATCH;
      }

    } // endif -- isKindOfClass
  }


  return score;

} // match


@end // @implementation SetCard_v2

