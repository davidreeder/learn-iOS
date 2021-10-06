//
// DiscardGroupingView.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "DiscardGroupingView.h"



//--------------------------------------------------------------- -o-
@interface DiscardGroupingView()

  /*EMPTY*/

@end // @interface DiscardGroupingView()




//--------------------------------------------------------------- -o-
#define HORIZONTAL_VIEW_POINTS_SEPARATION  5




//--------------------------------------------------------------- -o-
@implementation DiscardGroupingView


//------------------------ -o-
- (void) setGroup: (NSArray *)setCardMatchedGroup
{
  _group = setCardMatchedGroup;
  [self setNeedsDisplay];
}



//------------------------ -o-
// drawRect:
//
// self.group represents a set of matched Set Cards.
// Render each card and display them in close quarters.
//
- (void) drawRect: (CGRect)rect
{
  NSUInteger  groupCount   = [self.group count];
  NSArray    *sortedGroup;

  CGRect      subviewRect;
  CGFloat     subviewOriginX = 0;
  CGFloat     subviewWidth;


  if (groupCount > 0) {
    sortedGroup  = [self.group sortedArrayUsingSelector: @selector(compare:)];
    subviewWidth = 
      (self.bounds.size.width - (HORIZONTAL_VIEW_POINTS_SEPARATION * 2)) / groupCount;

    for (int i = 0; i < groupCount; i++)
    {
      subviewRect = CGRectMake(subviewOriginX, self.bounds.origin.y, 
				 subviewWidth, self.bounds.size.height);

      [[SetCardView imageFromSetCard: sortedGroup[i]
			      inRect: subviewRect]  drawInRect:subviewRect ];

      subviewOriginX += subviewWidth + HORIZONTAL_VIEW_POINTS_SEPARATION;

    } // endfor
  }

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

