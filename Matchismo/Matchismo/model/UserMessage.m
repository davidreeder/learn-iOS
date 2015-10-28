//
// UserMessage.m
//
// UserMessage is a utility class to provide user feedback
// that contains both text and card images.  
//
// UserMessage objects are initialized with an array of cards
// and current state for these cards.  It may also be initialized
// with a simple string, when cards need not be displayed.
//
// This state is enough to generate formatting information in 
// UserMessageView with the help of utility methods from SetCardView.
//
// UserMessage objects are kept in the history of actions, populated 
// by NSString objects in the other games.  
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "UserMessage.h"



//---------------------------------------------------- -o-
@interface UserMessage()

  @property  (readwrite, strong, nonatomic)  NSArray             *cards;

  @property  (readwrite, strong, nonatomic)  NSAttributedString  *attributedText;
  @property  (strong, nonatomic)             NSString            *text;

  @property  (nonatomic)                     BOOL                 isMatch;
  @property  (nonatomic)                     BOOL                 isFlipped;

  @property  (nonatomic)                     NSUInteger           numberOfPoints;

@end




//---------------------------------------------------- -o-
#define ATTRIBUTED_TEXT_FONT_SIZE  14

#define HORIZONTAL_OFFSET_BASE          66

#define HORIZONTAL_OFFSET_MATCH         (HORIZONTAL_OFFSET_BASE + 16)
#define HORIZONTAL_OFFSET_NO_MATCH      (HORIZONTAL_OFFSET_BASE + 25)

#define HORIZONTAL_OFFSET_FLIPPED_UP    (HORIZONTAL_OFFSET_BASE + 10)
#define HORIZONTAL_OFFSET_FLIPPED_DOWN  (HORIZONTAL_OFFSET_BASE +  0)



//---------------------------------------------------- -o-
@implementation UserMessage

//
// constructors
//

//------------------- -o-
- (id) initWithMessage: (NSString *)message 
{
  self = [super init];
  if (!self)  { return nil; }

  _text = message;

  [self generateMessage];
    
  return self;
}


//------------------- -o-
- (id) initWithCards: (NSArray *)   cardList 
             isMatch: (BOOL)        isMatch 
           andPoints: (NSUInteger)  points
{
  self = [super init];
  if (!self)  { return nil; }

  _cards           = cardList;
  _isMatch         = isMatch;
  _numberOfPoints  = points;

  _horizontalOffset = _isMatch 
    ? HORIZONTAL_OFFSET_MATCH : HORIZONTAL_OFFSET_NO_MATCH;

  [self generateMessage];

  return self;
}


//------------------- -o-
- (id) initWithCards: (NSArray *)  cardList 
           isFlipped: (BOOL)       isFlipped
{
  self = [super init];
  if (!self)  { return nil; }

  _cards      = cardList;
  _isFlipped  = isFlipped;

  _horizontalOffset = _isFlipped 
    ? HORIZONTAL_OFFSET_FLIPPED_UP : HORIZONTAL_OFFSET_FLIPPED_DOWN;

  [self generateMessage];

  return self;
}


//------------------- -o-
// generateMessage
//
// NB  Excessive spaces in string formatting are required to
//     provide exact amount of space (given ATTRIBUTED_TEXT_FONT_SIZE)
//     to interleave drawn Set cards into drawn text in UserMessageView. 
//
- (void) generateMessage
{
  NSUInteger cardCount = [self.cards count];


  //
  switch (cardCount)
  {
  case 0:                       // use given message
    /*EMPTY*/
    break;


  case 1:                       // flipped message
    self.text = 
      DP_STRWFMT(@"   is flipped %@.", self.isFlipped ? @"up" : @"down");
    break;


  case 3:                       // matched message
    if (self.isMatch) {
      self.text = DP_STRWFMT(@"Match:                           %lu points.", 
	            (unsigned long)self.numberOfPoints);
    } else {
      self.text = DP_STRWFMT(@"No match:                            Penalty %lu!", 
	            (unsigned long)self.numberOfPoints);
    }

    break;


  default:                      // XXX -- instead: throw exception
    [Log errorMsg:
      DP_STRWFMT(@"%@ :: generateMessage -- Incorrect number of cards!", 
        [self class])];
  }


  //
  NSMutableParagraphStyle *paragraphStyle = 
                              [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.alignment = NSTextAlignmentCenter;

  UIFont *systemFont = [UIFont boldSystemFontOfSize:ATTRIBUTED_TEXT_FONT_SIZE];
    
  self.attributedText = [[NSAttributedString alloc] 
      initWithString: self.text
          attributes: @{ NSParagraphStyleAttributeName : paragraphStyle, 
                         NSFontAttributeName           : systemFont 
                       }
    ];

} // generateMessage


@end

