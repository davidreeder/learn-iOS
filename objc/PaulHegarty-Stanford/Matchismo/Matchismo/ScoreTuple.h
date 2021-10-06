//
//  ScoreTuple.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "Danaprajna.h"



//---------------------------------------------------- -o--
@interface ScoreTuple : NSObject

  @property (nonatomic)          int            score;
  @property (nonatomic)          unsigned int   flipsCount;
  @property (strong, nonatomic)  NSDate        *date;
  @property (nonatomic)          unsigned int   gameVersion;
  @property (nonatomic)          unsigned int   matchGameType;


  // DESIGNATED INITIALIZER.
  //
  - (id) initWithScore: (int)          score__
            flipsCount: (unsigned int) flipsCount__
                  date: (NSDate *)     date__
           gameVersion: (unsigned int) gameVersion__
         matchGameType: (unsigned int) matchGameType__;

  - (id) initWithPropertyList: (id)plist;

  //
  - (NSDictionary *) propertyListValue;
  + (NSArray *)      arrayFromPropertyList: (NSArray *)plistArray;

  //
  - (NSComparisonResult) compareScore:      (ScoreTuple *)otherTuple;
  - (NSComparisonResult) compareFlipsCount: (ScoreTuple *)otherTuple;
  - (NSComparisonResult) compareDate:       (ScoreTuple *)otherTuple;

@end



//---------------------------------------------------- -o--

//
// Tags for ScoreTuple property list.
//

#define ST_SCORE        @"ST_SCORE"
#define ST_FLIPSCOUNT   @"ST_FLIPSCOUNT"
#define ST_DATE         @"ST_DATE"
#define ST_GAMETYPE     @"ST_GAMETYPE"
#define ST_GAMEVERSION  @"ST_GAMEVERSION"

