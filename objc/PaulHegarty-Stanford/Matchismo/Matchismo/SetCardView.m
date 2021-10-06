//
// SetCardView.m
//
// Draw Set Game symbols with NSBezierPath and background images.
//
// SetCardView is a thin view module that happens to contain a large object
//   definition to draw images.
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "SetCardView.h"



//--------------------------------------------------------------- -o--
@interface SetCardView()

  @property  (nonatomic)  CGPoint  gViewCenter;
      // NB  This does not seem to represent the actual horizontal center of the view?!

  @property  (nonatomic)  CGFloat  gWidthScalar;
  @property  (nonatomic)  CGFloat  gHeightScalar;

  @property  (nonatomic)  CGFloat  gWonkyHorizontalOffset;
      // XXX  Somehow...(?!)  Horizontal values greater than the maximum 
      //      height (self.bounds.size.height) are necessary to properly 
      //      center multiple instances of shape drawings.
      //


  @property  (nonatomic)  CGFloat  gShapeLineWidth;


  // Shape origins computed as follows:
  //   x = (<view center> + <shape offset>) * gWidthScalar
  //   y = (<view center> + <shape offset> + <wonky offset>) * gHeightScalar
  //
  // *_SCALE value is used relative to the shape itself.
  //
  // XXX  Shapes developed in view of size (gWidthMagic, gHeightMagic).
  //
  @property  (nonatomic)  CGPoint  gSquiggleOrigin;
  @property  (nonatomic)  CGFloat  gSquiggleScale;
  @property  (nonatomic)  CGPoint  gSquiggleScaleFractionalPoint;

  @property  (nonatomic)  CGPoint  gDiamondOrigin;
  @property  (nonatomic)  CGFloat  gDiamondScale;
  @property  (nonatomic)  CGPoint  gDiamondScaleFractionalPoint;

  @property  (nonatomic)  CGPoint  gTubeOrigin;
  @property  (nonatomic)  CGFloat  gTubeScale;
  @property  (nonatomic)  CGPoint  gTubeScaleFractionalPoint;


  @property  (nonatomic)  CGFloat  gVerticalAboveCenter;
  @property  (nonatomic)  CGFloat  gVerticalAboveEmpty;
  @property  (nonatomic)  CGFloat  gVerticalCenter;
  @property  (nonatomic)  CGFloat  gVerticalBelowEmpty;
  @property  (nonatomic)  CGFloat  gVerticalBelowCenter;


  //
  @property  (nonatomic)  CGRect   gLocalBounds;
      // Represents the absolute bounds in which a balanced card 
      //   image was originally drawn.


  //
  @property  (nonatomic)  UIColor  *darkishGreen;
  @property  (nonatomic)  UIColor  *dirtyYellow;


  //
  - (void) computeGlobals;
  - (void) drawCard;

  - (void) displayShadedBackgroundImage: (UIColor *)color;

  - (id) drawSquiggleWithSchema: (id)schema;
  - (id) drawDiamondWithSchema:  (id)schema;
  - (id) drawTubeWithSchema:     (id)schema;


  - (void) drawBorderWithColor: (UIColor *)color  
                  andLineWidth: (CGFloat)lineWidth;

@end // @interface SetCardView()



//--------------------------------------------------------------- -o-
// NSDictionary entries for schema passed as object to draw methods
//   via selector.
//
#define SCHEMA_COLOR            @"SCHEMA_COLOR"
#define SCHEMA_SHADE            @"SCHEMA_SHADE"
#define SCHEMA_VERTICAL         @"SCHEMA_VERTICAL"


// Abstracted colors: one, two, three.
//
#define COLOR_ONE    self.darkishGreen
#define COLOR_TWO    [UIColor purpleColor]
#define COLOR_THREE  [UIColor redColor]


#define ALPHA_DISABLED  0.0
#define ALPHA_OFF       1.0


// Parameters for roundedRect.
//
#define CORNER_RADIUS  12.0             // TBD -- As ratio of card size.

#define COLOR_SELECTED    [UIColor magentaColor] 
#define COLOR_UNSELECTED  [UIColor blackColor] 
#define COLOR_HINT        self.dirtyYellow

#define LINEWIDTH_SELECTED    9.0       // TBD -- As radio of card size.
#define LINEWIDTH_UNSELECTED  0.5



//--------------------------------------------------------------- -o--
@implementation SetCardView

#pragma mark - Class Methods

//------------------ -o-
+ (UIImage *) imageFromSetCard: (SetCard_v2 *)setcard  
                        inRect: (CGRect) rect
{

  SetCardView  *setCardView = [[SetCardView alloc] 
                                initWithFrame: rect
                                        count: setcard.count
                                        shape: setcard.shape
                                        color: setcard.color
                                        shade: setcard.shade ];
  [setCardView generateCardImage];

  return setCardView.setCardImage;
}


//------------------ -o-
+ (CGFloat) sizeRatio;
{
  return SETCARD_SIZE_RATIO;
}



//--------------------------------------------------------------- -o--
#pragma mark - Getters/Setters

- (void) setCount: (NSUInteger)count
{
  _count = count;
  [self setNeedsDisplay];
}


- (void) setShape: (SCShape)shape  
{
  _shape = shape;
  [self setNeedsDisplay];
}

- (void) setColor: (SCColor)color
{
  _color = color;
  [self setNeedsDisplay];
}

- (void) setShade: (SCShade)shade
{
  _shade = shade;
  [self setNeedsDisplay];
}




//--------------------------------------------------------------- -o--
#pragma mark - Methods

//------------------------ -o-
- (NSString *) description
{
  return [NSString stringWithFormat:@"%d of %@ with %@ and %@", 
    self.count, 
    (SCShapeOne == self.shape) 
      ? @"SCShapeOne" 
      : ((SCShapeTwo == self.shape) ? @"SCShapeTwo" : @"SCShapeThree"),
    (SCColorOne == self.color) 
      ? @"SCColorOne" 
      : ((SCColorTwo == self.color) ? @"SCColorTwo" : @"SCColorThree"),
    (SCShadeFull == self.shade) 
      ? @"SCShadeFull" 
      : ((SCShadePartial == self.shade) ? @"SCShadePartial" : @"SCShadeClear")
  ];
}




//--------------------------------------------------------------- -o--
#pragma mark - Drawing

//------------------------ -o-
// computeGlobals
//
// View boundary values based on normative card values during 
// UIBezierPath development with card of dimentions (x=66, y=87).  
// Now fixed as the image of the card.  XXX
//
// Scaling the image is more successful than scaling the math of
// image object relationships.
//
// See private @interface for further comments.
//
- (void) computeGlobals
{
  self.gLocalBounds = 
    CGRectMake( 0, 0, SETCARD_STANDARD_WIDTH, SETCARD_STANDARD_HEIGHT);  // XXX

  self.gViewCenter  = CGPointMake( self.gLocalBounds.size.width / 2, 
                                   self.gLocalBounds.size.height / 2 );


  // Magic values for image bounds.
  //
  self.gWidthMagic   = 150;
  self.gHeightMagic  = 160;

  self.gWidthOffsetMagic   = 65;
  self.gHeightOffsetMagic  = 150;


  self.gWidthScalar   = self.gLocalBounds.size.width / self.gWidthMagic;
  self.gHeightScalar  = self.gLocalBounds.size.height / self.gHeightMagic;

  self.gWonkyHorizontalOffset  = 355 * self.gHeightScalar;


  // Magic value for selection border.
  //
  self.gShapeLineWidth  = 8.0 * self.gWidthScalar;


  // Magic values for each shape.
  //
  self.gSquiggleOrigin = CGPointMake( 
      ((self.gViewCenter.x + 40) * self.gWidthScalar) 
        + self.gWidthOffsetMagic,                           
      ((self.gViewCenter.y - 160 + self.gWonkyHorizontalOffset) * self.gHeightScalar)
        + self.gHeightOffsetMagic
  );

  self.gSquiggleScale  = 0.25;
  self.gSquiggleScaleFractionalPoint  = CGPointMake(
      self.gSquiggleScale * self.gWidthScalar, self.gSquiggleScale * self.gHeightScalar);


  self.gDiamondOrigin = CGPointMake( 
      ((self.gViewCenter.x + 100) * self.gWidthScalar)
        + self.gWidthOffsetMagic,                           
      ((self.gViewCenter.y - 72 + self.gWonkyHorizontalOffset) * self.gHeightScalar)
        + self.gHeightOffsetMagic
  );

  self.gDiamondScale  = 0.25;
  self.gDiamondScaleFractionalPoint  = CGPointMake(
      self.gDiamondScale * self.gWidthScalar, self.gDiamondScale * self.gHeightScalar);


  self.gTubeOrigin = CGPointMake(    
      ((self.gViewCenter.x + 145) * self.gWidthScalar)
        + self.gWidthOffsetMagic,                           
      ((self.gViewCenter.y - 40 + self.gWonkyHorizontalOffset) * self.gHeightScalar)
        + self.gHeightOffsetMagic
  );

  self.gTubeScale  = 0.25;
  self.gTubeScaleFractionalPoint  = CGPointMake(
      self.gTubeScale * self.gWidthScalar, self.gTubeScale * self.gHeightScalar);


  // Magic values for spacing of multiple shapes.
  //
  self.gVerticalAboveCenter  = (-320 * self.gHeightScalar);
  self.gVerticalAboveEmpty   = (-160 * self.gHeightScalar);
  self.gVerticalCenter       = (   0 * self.gHeightScalar);
  self.gVerticalBelowEmpty   = ( 160 * self.gHeightScalar);
  self.gVerticalBelowCenter  = ( 320 * self.gHeightScalar);



  // Compute non-standard colors "once."
  //
  self.darkishGreen  = [Zed colorWith255Red:0    green:185  blue:0  alpha:1.0];    
  self.dirtyYellow   = [Zed colorWith255Red:224  green:207  blue:0  alpha:1.0]; 

} // computeGlobals



//------------------------ -o-
- (void) drawCard
{
  SEL  drawSelector = 
         (SCShapeOne == self.shape) 
           ? @selector(drawSquiggleWithSchema:)
           : ((SCShapeTwo == self.shape) 
               ? @selector(drawDiamondWithSchema:) : @selector(drawTubeWithSchema:));

  NSMutableDictionary  *schema = [[NSMutableDictionary alloc] init];

  UIColor  *useColor = (SCColorOne == self.color) 
                         ? COLOR_ONE
                         : ((SCColorTwo == self.color) ? COLOR_TWO : COLOR_THREE);

  [schema setObject:useColor       forKey:SCHEMA_COLOR];
  [schema setObject:@(self.shade)  forKey:SCHEMA_SHADE];


  // NB   self.count range is [1, SETCARD_COUNT_MAX]
  // XXX  #pragma's prevent warning from [self performSelector:...]
  //
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

  NSUInteger numShapes = self.count;
 
  if (1 == (numShapes % 2)) {                  // draw in center
    [schema setObject:@(self.gVerticalCenter) forKey:SCHEMA_VERTICAL];

  } else if (2 == numShapes) {                 // draw above empty center
    [schema setObject:@(self.gVerticalAboveEmpty) forKey:SCHEMA_VERTICAL];
  }

  [self performSelector:drawSelector withObject:schema];


  if (3 == numShapes) {                        // draw above drawn center
    [schema setObject:@(self.gVerticalAboveCenter) forKey:SCHEMA_VERTICAL];
    [self performSelector:drawSelector withObject:schema];
  }


  if (2 == numShapes) {                        // draw below empty center
    [schema setObject:@(self.gVerticalBelowEmpty) forKey:SCHEMA_VERTICAL];

  } else if (3 == numShapes) {                 // draw below drawn center
    [schema setObject:@(self.gVerticalBelowCenter) forKey:SCHEMA_VERTICAL];
  }

  [self performSelector:drawSelector withObject:schema];

#pragma clang diagnostic pop

} // drawCard



//------------------------ -o-
// generateCardImage
//
// Generate card image.
//
// Establish local graphic state so resulting image can be 
// composited with other images.
//
// NB  Draw card in gLocalBounds, but display card in self.bounds.
//
- (void) generateCardImage
{
  //
  [self computeGlobals];

  DP_GSTATE_SAVE();
  UIGraphicsBeginImageContext(self.gLocalBounds.size);


  // 
  UIBezierPath *roundedRect = 
    [UIBezierPath bezierPathWithRoundedRect: self.gLocalBounds 
                               cornerRadius: CORNER_RADIUS];
  [roundedRect addClip];
  
  [[UIColor whiteColor] setFill];
  UIRectFill(self.gLocalBounds);

  if (self.isFaceUp) {
    [self borderSelected];
  } else {
    if (self.isHinted) {
      [self borderHint];
    } else {
      [self borderUnselected];
    }
  }


  [self drawCard];
  self.setCardImage = UIGraphicsGetImageFromCurrentImageContext();


  //
  UIGraphicsEndImageContext();
  DP_GSTATE_RESTORE();

} // generateCardImageWithBounds:



//------------------------ -o-
// drawRect:
//
// NB  Draw card in gLocalBounds, but display card in self.bounds.
//
- (void) drawRect: (CGRect)rect
{
  [self generateCardImage];
  [self.setCardImage drawInRect:self.bounds];

} // drawRect:



//------------------------ -o-
// displayShadedBackgroundImage
//
// De-nature [NSBezierPath setLineDash...] to fill bounds of
// current view with stripes.  This background image will be clipped 
// by Set shapes to generate the "shaded" image.
//
- (void) displayShadedBackgroundImage:(UIColor *) color
{
  // Initialize image context.
  //
  CGSize backgroundImageSize = 
           CGSizeMake(self.gLocalBounds.size.width, self.gLocalBounds.size.height);
  UIGraphicsBeginImageContext(backgroundImageSize);


  // Create striped background by tweaking line dash method.
  //
  UIBezierPath  *bp = [[UIBezierPath alloc] init];

  CGFloat  dashArray[] = {4.5, 3};
  [bp setLineDash:dashArray count:2 phase:0];
  bp.lineWidth = 1000;  // XXX -- wider than containing rounded rect...

  [bp moveToPoint:CGPointMake(0, 0)];
  [bp addLineToPoint:CGPointMake(self.gLocalBounds.size.width, self.gLocalBounds.size.height)];

  [color setStroke];
  [bp stroke];


  // Finish image context.
  //
  UIImage *shadedBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
        

  // Display image.
  //
  CGRect imageRect = CGRectInset(self.gLocalBounds, 0, 0);
  [shadedBackgroundImage drawInRect:imageRect];

} // displayShadedBackground



//------------------ -o-
- (id) drawSquiggleWithSchema: (id)schema
{
  if (! [schema isKindOfClass:[NSDictionary class]]) 
  {
    DP_MARK(drawSquiggleWithSchema:);
    [Log errorMsg:@"schema is not an NSDictionary."];  // XXX  should throw exception
    return nil;
  }

  CGFloat   vertical  = [[schema objectForKey:SCHEMA_VERTICAL] floatValue];
  UIColor  *color     = [schema objectForKey:SCHEMA_COLOR];
  SCShade   shade     = [[schema objectForKey:SCHEMA_SHADE] unsignedIntegerValue];


  //
  DP_GSTATE_SAVE();

  UIBezierPath  *squiggle     = [[UIBezierPath alloc] init];
  CGPoint        usePosition  = CGPointMake(self.gSquiggleOrigin.x, self.gSquiggleOrigin.y + vertical);

  NSArray *squiggleMove = [NSArray arrayWithObjects:
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 0.0  , 156.0 )  toPoint:usePosition  scaleWithFractionalPoint:self.gSquiggleScaleFractionalPoint]],  // m0
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 228.0, 72.0 )   toPoint:usePosition  scaleWithFractionalPoint:self.gSquiggleScaleFractionalPoint]],  // m1
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 384.0, 60.0 )   toPoint:usePosition  scaleWithFractionalPoint:self.gSquiggleScaleFractionalPoint]],  // m2
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 420.0, 108.0 )  toPoint:usePosition  scaleWithFractionalPoint:self.gSquiggleScaleFractionalPoint]],  // m3
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 204.0, 168.0 )  toPoint:usePosition  scaleWithFractionalPoint:self.gSquiggleScaleFractionalPoint]],  // m4
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 36.0 , 180.0 )  toPoint:usePosition  scaleWithFractionalPoint:self.gSquiggleScaleFractionalPoint]],  // m5
      nil];

  NSArray *squiggleControl = [NSArray arrayWithObjects:
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 0.0  , 0.0 )    toPoint:usePosition  scaleWithFractionalPoint:self.gSquiggleScaleFractionalPoint]],  // c0
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 300.0, 96.0 )   toPoint:usePosition  scaleWithFractionalPoint:self.gSquiggleScaleFractionalPoint]],  // c1
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 432.0, 48.0 )   toPoint:usePosition  scaleWithFractionalPoint:self.gSquiggleScaleFractionalPoint]],  // c2
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 396.0, 240.0 )  toPoint:usePosition  scaleWithFractionalPoint:self.gSquiggleScaleFractionalPoint]],  // c3
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 96.0 , 132.0 )  toPoint:usePosition  scaleWithFractionalPoint:self.gSquiggleScaleFractionalPoint]],  // c4
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 0.0  , 204.0 )  toPoint:usePosition  scaleWithFractionalPoint:self.gSquiggleScaleFractionalPoint]],  // c5
      nil];


  //
  [squiggle moveToPoint:[squiggleMove[0] CGPointValue]];
  [squiggle addQuadCurveToPoint: [squiggleMove[1] CGPointValue] 
                   controlPoint: [squiggleControl[0] CGPointValue]];
  [squiggle addQuadCurveToPoint: [squiggleMove[2] CGPointValue] 
                   controlPoint: [squiggleControl[1] CGPointValue]];
  [squiggle addQuadCurveToPoint: [squiggleMove[3] CGPointValue] 
                   controlPoint: [squiggleControl[2] CGPointValue]];
  [squiggle addQuadCurveToPoint: [squiggleMove[4] CGPointValue] 
                   controlPoint: [squiggleControl[3] CGPointValue]];
  [squiggle addQuadCurveToPoint: [squiggleMove[5] CGPointValue] 
                   controlPoint: [squiggleControl[4] CGPointValue]];
  [squiggle addQuadCurveToPoint: [squiggleMove[0] CGPointValue] 
                   controlPoint: [squiggleControl[5] CGPointValue]];

  [squiggle closePath];
  [squiggle addClip];


  //
  CGFloat  useAlpha = (SCShadeFull == shade) ? ALPHA_OFF : ALPHA_DISABLED;

  if (SCShadePartial == shade) {
    [self displayShadedBackgroundImage:color];
  }

  [[color colorWithAlphaComponent:useAlpha] setFill];
  squiggle.lineWidth = self.gShapeLineWidth;
  [color setStroke];

  [squiggle fill];
  [squiggle stroke];

  DP_GSTATE_RESTORE();


  return nil;

}  // drawSquiggleWithSchema:



//------------------ -o-
- (id) drawDiamondWithSchema: (id)schema
{
  if (! [schema isKindOfClass:[NSDictionary class]]) 
  {
    DP_MARK(drawDiamondWithSchema:);
    [Log errorMsg:@"schema is not NSDictionary."];  // XXX  should throw exception 
    return nil;
  }

  CGFloat   vertical  = [[schema objectForKey:SCHEMA_VERTICAL] floatValue];
  UIColor  *color     = [schema objectForKey:SCHEMA_COLOR];
  SCShade   shade     = [[schema objectForKey:SCHEMA_SHADE] unsignedIntegerValue];


  //
  DP_GSTATE_SAVE();

  UIBezierPath  *diamond      = [[UIBezierPath alloc] init];
  CGPoint        usePosition  = CGPointMake(self.gDiamondOrigin.x, self.gDiamondOrigin.y + vertical);

  NSArray *diamondMove = [NSArray arrayWithObjects:
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 0.0  , 72.0 )   toPoint:usePosition  scaleWithFractionalPoint:self.gDiamondScaleFractionalPoint]],  // left
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 180.0, 0.0 )    toPoint:usePosition  scaleWithFractionalPoint:self.gDiamondScaleFractionalPoint]],  // top
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 360.0, 72.0 )   toPoint:usePosition  scaleWithFractionalPoint:self.gDiamondScaleFractionalPoint]],  // right
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 180.0, 144.0 )  toPoint:usePosition  scaleWithFractionalPoint:self.gDiamondScaleFractionalPoint]],  // bottom
      nil];


  //
  [diamond moveToPoint:[diamondMove[0] CGPointValue]];
  [diamond addLineToPoint:[diamondMove[1] CGPointValue]];
  [diamond addLineToPoint:[diamondMove[2] CGPointValue]];
  [diamond addLineToPoint:[diamondMove[3] CGPointValue]];

  [diamond closePath];
  [diamond addClip];


  //
  CGFloat  useAlpha = (SCShadeFull == shade) ? ALPHA_OFF : ALPHA_DISABLED;

  if (SCShadePartial == shade) {
    [self displayShadedBackgroundImage:color];
  }

  [[color colorWithAlphaComponent:useAlpha] setFill];
  diamond.lineWidth = self.gShapeLineWidth;
  [color setStroke];

  [diamond fill];
  [diamond stroke];

  DP_GSTATE_RESTORE();


  return nil;

} // drawDiamondWithSchema:



//------------------ -o-
- (id) drawTubeWithSchema: (id)schema
{
  if (! [schema isKindOfClass:[NSDictionary class]]) 
  {
    DP_MARK(drawTubeWithSchema:);
    [Log errorMsg:@"schema is not NSDictionary."];  // XXX  should throw exception 
    return nil;
  }

  CGFloat   vertical  = [[schema objectForKey:SCHEMA_VERTICAL] floatValue];
  UIColor  *color     = [schema objectForKey:SCHEMA_COLOR];
  SCShade   shade     = [[schema objectForKey:SCHEMA_SHADE] unsignedIntegerValue];


  //
  DP_GSTATE_SAVE();

  UIBezierPath  *tube         = [[UIBezierPath alloc] init];
  CGPoint        usePosition  = CGPointMake(self.gTubeOrigin.x, self.gTubeOrigin.y + vertical);

  NSArray *tubeMove = [NSArray arrayWithObjects:
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 30.0 , 0.0 )    toPoint:usePosition  scaleWithFractionalPoint:self.gTubeScaleFractionalPoint]],
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 278.0, 0.0 )    toPoint:usePosition  scaleWithFractionalPoint:self.gTubeScaleFractionalPoint]],
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 278.0, 120.0 )  toPoint:usePosition  scaleWithFractionalPoint:self.gTubeScaleFractionalPoint]], // XXX  unused
      [NSValue valueWithCGPoint:
        [Zed cgAddPoint:CGPointMake( 30.0 , 120.0 )  toPoint:usePosition  scaleWithFractionalPoint:self.gTubeScaleFractionalPoint]],
      nil];

  CGPoint upperLeft  = [tubeMove[0] CGPointValue];
  CGPoint upperRight = [tubeMove[1] CGPointValue];
  CGPoint lowerLeft  = [tubeMove[2] CGPointValue];
  CGFloat radius     = (lowerLeft.y - upperLeft.y) / 2;


  //
  [tube moveToPoint:[tubeMove[0] CGPointValue]];
  [tube addLineToPoint:[tubeMove[1] CGPointValue]];

  [tube addArcWithCenter: CGPointMake(upperRight.x, upperRight.y + radius)
                  radius: radius
              startAngle: M_PI * 3/2
                endAngle: M_PI * 1/2
               clockwise: YES ];

  [tube addLineToPoint:[tubeMove[3] CGPointValue]];

  [tube addArcWithCenter: CGPointMake(upperLeft.x, upperLeft.y + radius)
                  radius: radius
              startAngle: M_PI * 1/2
                endAngle: M_PI * 3/2
               clockwise: YES ];

  [tube closePath];
  [tube addClip];


  //
  CGFloat  useAlpha = (SCShadeFull == shade) ? ALPHA_OFF : ALPHA_DISABLED;

  if (SCShadePartial == shade) {
    [self displayShadedBackgroundImage:color];
  }

  [[color colorWithAlphaComponent:useAlpha] setFill];
  tube.lineWidth = self.gShapeLineWidth;
  [color setStroke];

  [tube fill];
  [tube stroke];

  DP_GSTATE_RESTORE();


  return nil;

} // drawTubeWithSchema:




//------------------ -o-
// drawBorderWithColor:andLineWidth: 
//
// XXX  roundedRect must match that in drawRect:.
//
- (void) drawBorderWithColor: (UIColor *)color  
                andLineWidth: (CGFloat)lineWidth
{
  UIBezierPath *roundedRect = 
    [UIBezierPath bezierPathWithRoundedRect: self.gLocalBounds
                               cornerRadius: CORNER_RADIUS];

  roundedRect.lineWidth = lineWidth;
  [color setStroke];
  [roundedRect stroke];

  [self setNeedsDisplay];
}


- (void) borderUnselected
{
  [self drawBorderWithColor: COLOR_UNSELECTED  
               andLineWidth: LINEWIDTH_UNSELECTED];
}

- (void) borderSelected
{
  [self drawBorderWithColor: COLOR_SELECTED  
               andLineWidth: LINEWIDTH_SELECTED];
}

- (void) borderHint
{
  [self drawBorderWithColor: COLOR_HINT  
               andLineWidth: LINEWIDTH_SELECTED];
}




//--------------------------------------------------------------- -o--
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
- (id)initWithFrame:(CGRect)frame               // DESIGNATED INITIALIZER
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

//------------------ -o-
- (id)initWithFrame: (CGRect)     frame         // SUPPLEMENTARY INITIALIZER
              count: (NSUInteger) count
              shape: (SCShape)    shape
              color: (SCColor)    color
              shade: (SCShade)    shade
{
  self = [self initWithFrame:frame];

  if (!self)  { return nil; }

  _count = count;
  _shape = shape;
  _color = color;
  _shade = shade;

  return self;
}


@end

