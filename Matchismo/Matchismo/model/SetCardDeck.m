//
// SetCardDeck.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "SetCardDeck.h"



//---------------------------------------------------- -o-
@interface SetCardDeck()

  @property (readwrite, strong, nonatomic)  NSDictionary  *cardDict;

@end



//---------------------------------------------------- -o-
@implementation SetCardDeck

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
            SetCard *card = [[SetCard alloc] initWithShape: shape
                                                     color: color
                                                     shade: shade
                                                     count: i ];
            [self addCard:card atTop:YES];
            [dictionaryOfCards setObject:card forKey:[card description]];
          }
        }
      }
    }

    self.cardDict = dictionaryOfCards;


#ifdef debug
  [Dump lp: [NSString stringWithFormat:@"ALL CARDS (%d)", [self.cardDict count]]
      objs: [[self.cardDict allKeys] sortedArrayUsingComparator:DP_BLOCK_CMPSTR] ];
#endif

  } // endif


  return self;

} // init




//---------------------------------------------------- -o-
// getters/setters
//

//------------------- -o-
- (void) setCardDict:(NSMutableDictionary *)mutableDict
{
  _cardDict = [mutableDict copy];
}



//---------------------------------------------------- -o-
// class methods
//


//------------------- -o-
+ (NSAttributedString *)convertToAttributedString: (NSString *)cardMsg
                                         withDeck: (SetCardDeck *)deck
{
  NSRange position = NSMakeRange(0, [cardMsg length]),
          result;

  NSMutableArray *rangeList = [[NSMutableArray alloc] init];

  NSMutableAttributedString *rval;



  // Create a list of NSRange objects, one to index each card in cardMsg. 
  //
  // XXX  Hardwired for current strings: the only numbers in the
  //      non-attributed string will come from cards and point values, 
  //      where no more than three cards will always come at the 
  //      head of the string.
  //
  // NB   rangeList inserts at head, so conversions occur in reverse order.
  //      Once card description is changed, target string changes length...
  //
  while (YES) {
    result = [cardMsg 
      rangeOfCharacterFromSet: [NSCharacterSet decimalDigitCharacterSet]
                      options: NSLiteralSearch
                        range: position ];

    if (result.location == NSNotFound)  { break; }

    result.length = SETCARD_DESCRIPTION_LENGTH;
    [rangeList insertObject:[NSValue valueWithRange:result] atIndex:0];

    if (3 <= [rangeList count])  { break; }

    position = 
      NSMakeRange(result.location+1, [cardMsg length] - (result.location+1));

  } // endwhile



  // Rewrite SetCard ASCII descriptions as NSAttributedStrings.
  //
  rval = [[NSMutableAttributedString alloc] initWithString:cardMsg];

  if (0 == [rangeList count])  { return [rval copy]; }


  for (NSValue *valobj in rangeList)
  {
    NSRange    cardrange = [valobj rangeValue];
    NSString  *cardkey   = [cardMsg substringWithRange:cardrange];
    SetCard   *setcard   = [deck.cardDict objectForKey:cardkey];

    [rval replaceCharactersInRange: cardrange
              withAttributedString: [setcard descriptionWithAttributedString]];
  }


  // Adapt font size per string length to fit width of given UILabel.
  //
  // XXX  Magic numbers based on known range of description strings...
  //
  float fontsize = [Zed scaleValue: [rval length] 
                            fromX1: 18  y1: 48    // string length
                            intoX2: 9   y2: 18    // font size
                       invertedMap: YES           // shrink font as 
                           rounded: NO            //   string lengthens
                   ];

  NSDictionary  *fontattr = @{
    NSFontAttributeName : [UIFont systemFontOfSize:fontsize],
  };

  [rval addAttributes:fontattr range:NSMakeRange(0, [rval length])];


  return [rval copy];

} // convertToAttributedString:


@end // @implementation SetCardDeck

