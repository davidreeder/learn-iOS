//
// ZedCG.m
//
// CGPoint arithmetic and scaling.
//
//
// CLASS METHODS--
//   cgAddPoint:toPoint:
//   cgScalePoint:withScalar:
//   cgScalePoint:withFractionalPoint:
//   cgAddPoint:toPoint:thenScale:
//   cgAddPoint:toPoint:scaleWithFractionalPoint:
//
//
// CLASS DEPENDENCIES: n/a
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2014.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "ZedCG.h"



//---------------------------------------------------- -o--
@implementation ZedCG

#pragma mark - CGPoint arithmetic and scaling.


//------------------- -o-
+ (CGPoint) cgAddPoint: (CGPoint)A  
               toPoint: (CGPoint)B
{
  return CGPointMake(A.x + B.x, A.y + B.y);
}


//------------------- -o-
// cgScalePoint:withFractionalPoint: 
//
// fractionalPoint contains ratios for X and Y axes;
//   does not represent a real point.
//
+ (CGPoint) cgScalePoint: (CGPoint)A  
     withFractionalPoint: (CGPoint)fractionalPoint
{
  return CGPointMake(A.x * fractionalPoint.x, A.y * fractionalPoint.y);
}


//------------------- -o-
// XXX  Optimize by avoiding reduction to other methods...
//
+ (CGPoint) cgScalePoint: (CGPoint)A  
              withScalar: (CGFloat)scalar
{
  return [ZedCG cgScalePoint:A withFractionalPoint:CGPointMake(scalar, scalar)];
}


//------------------- -o-
+ (CGPoint)     cgAddPoint: (CGPoint)A  
                   toPoint: (CGPoint)B 
  scaleWithFractionalPoint: (CGPoint)fractionalPoint
{
  return [ZedCG    cgScalePoint: [ZedCG cgAddPoint:A toPoint:B] 
            withFractionalPoint: fractionalPoint];
}


//------------------- -o-
+ (CGPoint) cgAddPoint: (CGPoint)A  
               toPoint: (CGPoint)B 
             thenScale: (CGFloat)scalar
{
  return [ZedCG cgScalePoint:[ZedCG cgAddPoint:A toPoint:B] withScalar:scalar];
}


@end // ZedCG

