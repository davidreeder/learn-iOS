//
// MatchCardView.m
//
// Adapted directly from P.Hegarty "PlayingCardView.m".
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "MatchCardView.h"



//--------------------------------------------------------------- -o-
@interface MatchCardView()

  @property (nonatomic) CGFloat faceCardScaleFactor;


  - (NSString *) rankAsString;

  - (void) drawCorners;

  - (void) pushContextAndRotateUpsideDown;

  - (void) popContext;

  - (void) drawPips;

  - (void) drawPipsWithHorizontalOffset: (CGFloat) hoffset
                         verticalOffset: (CGFloat) voffset
                             upsideDown: (BOOL)    upsideDown;

  - (void) drawPipsWithHorizontalOffset: (CGFloat)hoffset
                         verticalOffset: (CGFloat)voffset
                     mirroredVertically: (BOOL)mirroredVertically;

  - (void) setup;

@end



//--------------------------------------------------------------- -o-
#define DEFAULT_FACE_CARD_SCALE_FACTOR  0.90

#define CORNER_RADIUS                   12.0
#define CORNER_OFFSET                   2.0

#define PIP_FONT_SCALE_FACTOR           0.18  // WAS: 0.20

#define PIP_SCALAR                      1.0

#define PIP_HOFFSET_PERCENTAGE          (0.165 * PIP_SCALAR)
#define PIP_VOFFSET1_PERCENTAGE         (0.090 * PIP_SCALAR)
#define PIP_VOFFSET2_PERCENTAGE         (0.175 * PIP_SCALAR)
#define PIP_VOFFSET3_PERCENTAGE         (0.270 * PIP_SCALAR)



//--------------------------------------------------------------- -o-
@implementation MatchCardView

  @synthesize faceCardScaleFactor = _faceCardScaleFactor;


#pragma mark - Properties

- (CGFloat)faceCardScaleFactor
{
  if (!_faceCardScaleFactor) {
    _faceCardScaleFactor = DEFAULT_FACE_CARD_SCALE_FACTOR;
  }
  return _faceCardScaleFactor;
}


- (void)setFaceCardScaleFactor:(CGFloat)faceCardScaleFactor
{
    _faceCardScaleFactor = faceCardScaleFactor;
    [self setNeedsDisplay];
}


- (void)setSuit:(NSString *)suit
{
    _suit = suit;
    [self setNeedsDisplay];
}


- (void)setRank:(NSUInteger)rank
{
    _rank = rank;
    [self setNeedsDisplay];
}


- (void)setFaceUp:(BOOL)faceUp
{
    _faceUp = faceUp;
    [self setNeedsDisplay];
}


- (NSString *)rankAsString
{
    return 
      @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"]
        [self.rank];
}



//--------------------------------------------------------------- -o-
#pragma mark - Drawing


//------------------ -o-
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *roundedRect = 
      [UIBezierPath bezierPathWithRoundedRect: self.bounds 
                                 cornerRadius: CORNER_RADIUS];
    [roundedRect addClip];
    
    [[UIColor whiteColor] setFill];
    UIRectFill(self.bounds);
    

    if (self.faceUp) 
    {
        UIImage *faceImage = 
          [UIImage imageNamed:[NSString stringWithFormat:@"%@%@.jpg", [self rankAsString], self.suit]];

        if (faceImage) {
            CGRect imageRect = CGRectInset(self.bounds,
                                           self.bounds.size.width * (1.0 - self.faceCardScaleFactor),
                                           self.bounds.size.height * (1.0 - self.faceCardScaleFactor));
            [faceImage drawInRect:imageRect];

        } else {
            [self drawPips];
        }

        [self drawCorners];

    } else {
        [[UIImage imageNamed:@"cardback.png"] drawInRect:self.bounds];
    }

    [[UIColor blackColor] setStroke];
    [roundedRect stroke];
}



//------------------ -o-
- (void)drawCorners
{
    NSMutableParagraphStyle *paragraphStyle = 
      [[NSMutableParagraphStyle alloc] init];

    paragraphStyle.alignment = NSTextAlignmentCenter;
    

    UIFont *cornerFont = 
      [UIFont systemFontOfSize:self.bounds.size.width * PIP_FONT_SCALE_FACTOR];
    
    NSAttributedString *cornerText = 
      [[NSAttributedString alloc] 
        initWithString: [NSString stringWithFormat:@"%@\n%@", [self rankAsString], self.suit] 
            attributes: @{ NSParagraphStyleAttributeName : paragraphStyle, 
                           NSFontAttributeName           : cornerFont 
                         }
      ];
    
    CGRect textBounds;
    textBounds.origin = CGPointMake(CORNER_OFFSET, CORNER_OFFSET);
    textBounds.size   = [cornerText size];
    [cornerText drawInRect:textBounds];
    
    [self pushContextAndRotateUpsideDown];
    [cornerText drawInRect:textBounds];
    [self popContext];
}


//------------------ -o-
- (void)pushContextAndRotateUpsideDown
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, self.bounds.size.width, self.bounds.size.height);
    CGContextRotateCTM(context, M_PI);
}


//------------------ -o-
- (void)popContext
{
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}



//--------------------------------------------------------------- -o-
#pragma mark - Gesture Handlers

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
  if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) 
  {
    self.faceCardScaleFactor *= gesture.scale;
    gesture.scale = 1;
  }
}



//--------------------------------------------------------------- -o-
#pragma mark - Draw Pips

//------------------ -o-
- (void)drawPips
{
    if ((self.rank == 1) || (self.rank == 5) || (self.rank == 9) || (self.rank == 3)) {
        [self drawPipsWithHorizontalOffset:0
                            verticalOffset:0
                        mirroredVertically:NO];
    }

    if ((self.rank == 6) || (self.rank == 7) || (self.rank == 8)) {
        [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
                            verticalOffset:0
                        mirroredVertically:NO];
    }

    if ((self.rank == 2) || (self.rank == 3) || (self.rank == 7) || (self.rank == 8) || (self.rank == 10)) {
        [self drawPipsWithHorizontalOffset:0
                            verticalOffset:PIP_VOFFSET2_PERCENTAGE
                        mirroredVertically:(self.rank != 7)];
    }

    if ((self.rank == 4) || (self.rank == 5) || (self.rank == 6) || (self.rank == 7) || (self.rank == 8) || (self.rank == 9) || (self.rank == 10)) {
        [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
                            verticalOffset:PIP_VOFFSET3_PERCENTAGE
                        mirroredVertically:YES];
    }

    if ((self.rank == 9) || (self.rank == 10)) {
        [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
                            verticalOffset:PIP_VOFFSET1_PERCENTAGE
                        mirroredVertically:YES];
    }
}

//------------------ -o-
- (void)drawPipsWithHorizontalOffset: (CGFloat) hoffset
                      verticalOffset: (CGFloat) voffset
                          upsideDown: (BOOL)    upsideDown
{
  if (upsideDown) {
    [self pushContextAndRotateUpsideDown];
  }

  CGPoint   middle = 
    CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
  UIFont   *pipFont = 
    [UIFont systemFontOfSize:self.bounds.size.width * PIP_FONT_SCALE_FACTOR];

  NSAttributedString *attributedSuit = 
    [[NSAttributedString alloc] 
      initWithString: self.suit 
          attributes: @{ NSFontAttributeName : pipFont }];

  CGSize    pipSize = [attributedSuit size];

  CGPoint   pipOrigin = 
    CGPointMake(
      middle.x - (pipSize.width/2.0)  - (hoffset*self.bounds.size.width),
      middle.y - (pipSize.height/2.0) - (voffset*self.bounds.size.height)
    );

  [attributedSuit drawAtPoint:pipOrigin];

  if (hoffset) {
    pipOrigin.x += hoffset * 2.0 * self.bounds.size.width;
    [attributedSuit drawAtPoint:pipOrigin];
  }

  if (upsideDown) {
    [self popContext];
  }
} // drawPipsWithHorizontalOffset:verticalOffset:upsideDown: 


//------------------ -o-
- (void)drawPipsWithHorizontalOffset: (CGFloat)hoffset
                      verticalOffset: (CGFloat)voffset
                  mirroredVertically: (BOOL)mirroredVertically
{
    [self drawPipsWithHorizontalOffset: hoffset
                        verticalOffset: voffset
                            upsideDown: NO];

    if (mirroredVertically) 
    {
        [self drawPipsWithHorizontalOffset: hoffset
                            verticalOffset: voffset
                                upsideDown: YES];
    }
}



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

@end // @implementation MatchCardView

