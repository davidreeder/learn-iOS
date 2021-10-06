//
// SectionTitleView.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "SectionTitleView.h"



//--------------------------------------------------------------- -o-
@interface SectionTitleView()

  @property  (strong, nonatomic)  NSAttributedString  *attributedText;

@end // @interface SectionTitleView()



//--------------------------------------------------------------- -o-
#define SECTION_SUPPLEMENTARY_VIEW_FONT_SIZE  22



//--------------------------------------------------------------- -o-
@implementation SectionTitleView


//------------------------ -o-
// newText
//
// Adapt external string into local attributed text tailored for display. 
//
- (void) setText: (NSString *)newText
{
  _text = newText;

  if ([newText length] <= 0) {
    newText = @"❦";
  }

  NSMutableParagraphStyle  *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.alignment = NSTextAlignmentCenter;
    
  UIFont  *titleFont = [UIFont italicSystemFontOfSize:SECTION_SUPPLEMENTARY_VIEW_FONT_SIZE];
    
  self.attributedText = [[NSAttributedString alloc] 
    initWithString: newText
        attributes: @{ NSParagraphStyleAttributeName : paragraphStyle, 
                       NSFontAttributeName           : titleFont 
                     }
                        ];


  [self setNeedsDisplay];
}


//------------------------ -o-
// drawRect:
//
- (void) drawRect: (CGRect)rect
{
  [self.attributedText drawInRect:self.bounds]; 

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

