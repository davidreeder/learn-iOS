//
// ZedCG.h
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2014.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#define DP_VERSION_ZEDCG  0.1


#import "Danaprajna.h"



//---------------------------------------------------- -o-
#define DP_ZEDCG_DEBUG_ENABLED  YES       // DEBUG

//
#define DP_GSTATE_SAVE()                                         \
    CGContextRef dpCGContextRef = UIGraphicsGetCurrentContext(); \
    CGContextSaveGState(dpCGContextRef);

#define DP_GSTATE_RESTORE() \
    CGContextRestoreGState(UIGraphicsGetCurrentContext());



//---------------------------------------------------- -o-
@interface ZedCG : NSObject

  + (CGPoint) cgAddPoint: (CGPoint)A  
                 toPoint: (CGPoint)B;

  + (CGPoint) cgScalePoint: (CGPoint)A  
                withScalar: (CGFloat)scalar;

  + (CGPoint) cgScalePoint: (CGPoint)A  
       withFractionalPoint: (CGPoint)fractionalPoint;

  + (CGPoint) cgAddPoint: (CGPoint)A  
                 toPoint: (CGPoint)B 
               thenScale: (CGFloat)scalar;

  + (CGPoint)     cgAddPoint: (CGPoint)A  
                     toPoint: (CGPoint)B 
    scaleWithFractionalPoint: (CGPoint)fractionalPoint;

@end // ZedCG

