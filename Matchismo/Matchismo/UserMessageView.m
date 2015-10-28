//
// UserMessageView.m
//
// Renders a user post window for each action in the view based
// on the utility object UserMessage, generated within the model.
//
// ASSUME  UIView containing UserMessageView will have a fixed 
//         width and height of (280, 27) in all views!
//

#import "UserMessageView.h"



//--------------------------------------------------------------- -o-
#define VERTICAL_CENTER_OFFSET 	(1.0/4.0)

#define CARD_HEIGHT_OFFSET     0.0
#define CARD_WIDTH_SEPARATION  2.0




//--------------------------------------------------------------- -o-
@implementation UserMessageView


//------------------------ -o-
- (void) setMessageData: (id)messageData
{
  _messageData = messageData;
  [self setNeedsDisplay];
}



//------------------------ -o-
- (void) renderCardImages
{
  NSUInteger cardCount         = [self.messageData.cards count];
  CGFloat    horizontalOffset  = self.messageData.horizontalOffset;

  CGFloat cardHeight  = self.bounds.size.height - (CARD_HEIGHT_OFFSET * 2),
	  cardWidth   = SETCARD_SIZE_RATIO * cardHeight;

  CGRect cardBounds;


  //
  switch (cardCount)
  {
  case 0: 		// do nothing
    {
      break;
    }


  case 1:
    {
      cardBounds = CGRectMake( horizontalOffset, CARD_HEIGHT_OFFSET,
			       cardWidth, cardHeight );

      [[SetCardView imageFromSetCard: self.messageData.cards[0]
			      inRect: cardBounds]  drawInRect:cardBounds ];
      break;
    }


  case 3:
    {
      NSArray *sortedCards = [self.messageData.cards sortedArrayUsingSelector: @selector(compare:)];

      for (int i = 0; i < cardCount; i++)
      {
	cardBounds = CGRectMake( horizontalOffset, CARD_HEIGHT_OFFSET,
				 cardWidth, cardHeight );

	[[SetCardView imageFromSetCard: sortedCards[i]
				inRect: cardBounds]  drawInRect:cardBounds ];

	horizontalOffset += cardWidth + CARD_WIDTH_SEPARATION;
      }

      break;
    }


  default:
    {
      [Log errorMsg: 	// XXX -- throw exception
	DP_STRWFMT(@"%@ :: renderCardImages -- wrong number of cards. (%lu)",
	  [self class], (unsigned long) cardCount) ];
    }
  }

} // renderCardImages



//------------------------ -o-
- (void) drawRect: (CGRect)rect
{
  CGRect verticalCenter = 
    CGRectMake( 0, self.bounds.size.height * VERTICAL_CENTER_OFFSET,
                self.bounds.size.width, self.bounds.size.height );

  [self.messageData.attributedText drawInRect:verticalCenter];
  [self renderCardImages];

} // drawRect:




//--------------------------------------------------------------- -o-
#pragma mark - Initialization

//------------------ -o-
- (void)setup
{
    // do initialization here
}

//------------------ -o-
- (void)awakeFromNib
{
    [self setup];
}

//------------------ -o-
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

@end

