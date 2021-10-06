//
// UserMessage.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Danaprajna.h"



//---------------------------------------------------- -o-
@interface UserMessage : NSObject

  @property  (readonly, strong, nonatomic)  NSArray             *cards;

  @property  (readonly, strong, nonatomic)  NSAttributedString  *attributedText;
   
  @property  (readonly, nonatomic)          NSInteger            horizontalOffset;
     // Number of points to indent before drawing elements of cards array.


  //
  - (id) initWithMessage: (NSString *)message; 

  - (id) initWithCards: (NSArray *)   cardList 
               isMatch: (BOOL)        isMatch 
             andPoints: (NSUInteger)  points;

  - (id) initWithCards: (NSArray *)  cardList 
             isFlipped: (BOOL)       isFlipped;

  - (void) generateMessage;

@end

