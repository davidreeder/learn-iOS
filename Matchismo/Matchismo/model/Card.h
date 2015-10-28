//
// Card.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



//---------------------------------------------------- -o-
@interface Card : NSObject


  @property (strong, nonatomic)               NSString  *contents;

  @property (nonatomic, getter=isFaceUp)      BOOL       faceUp;
  @property (nonatomic, getter=isUnplayable)  BOOL       unplayable;


  - (int) match: (NSArray *)otherCards;


@end // Card

