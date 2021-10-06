//
//  ScoreTuple.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "ScoreTuple.h"



//---------------------------------------------------- -o-
@implementation ScoreTuple


//-------------------------------------- -o-
- (id) initWithScore: (int)          score__            // DESIGNNATED INITIALIZER.
          flipsCount: (unsigned int) flipsCount__
                date: (NSDate *)     date__
         gameVersion: (unsigned int) gameVersion__
       matchGameType: (unsigned int) matchGameType__
{
  self = [super init];

  if (self) {
    _score          = score__;
    _flipsCount     = flipsCount__;
    _date           = date__;
    _gameVersion    = gameVersion__;
    _matchGameType  = matchGameType__;
  }

  return self;
}


//-------------- -o-
// initWithPropertyList:
//
// NB  For some games, ST_GAMETYPE is missing.
//
// CONVENIENCE INITIALIZER.
//
- (id) initWithPropertyList: (id) plist
{
  self = [self init];

  if (self) {
    if ([plist isKindOfClass:[NSDictionary class]]) 
    {
      NSDictionary *dict = (NSDictionary *)plist;

      _score          = [dict[ST_SCORE]       integerValue];
      _flipsCount     = [dict[ST_FLIPSCOUNT]  integerValue];
      _date           =  dict[ST_DATE];
      _gameVersion    = [dict[ST_GAMEVERSION] integerValue];
      _matchGameType  = [dict[ST_GAMETYPE]    integerValue];
    }
  }

  return self;
}




//-------------------------------------- -o-
- (NSDictionary *) propertyListValue
{
  if (self.matchGameType) {
    return @{ ST_SCORE          : @(self.score), 
              ST_FLIPSCOUNT     : @(self.flipsCount), 
              ST_DATE           : self.date, 
              ST_GAMEVERSION    : @(self.gameVersion),
              ST_GAMETYPE       : @(self.matchGameType) 
            };

  } else {
    return @{ ST_SCORE          : @(self.score), 
              ST_FLIPSCOUNT     : @(self.flipsCount), 
              ST_DATE           : self.date, 
              ST_GAMEVERSION    : @(self.gameVersion) 
            };
  }
}


//-------------------------------------- -o-
+ (NSArray *) arrayFromPropertyList: (NSArray *) plistArray
{
  ScoreTuple            *st;
  NSMutableArray        *stArray = [[NSMutableArray alloc] init];

  for (id plist in plistArray) {
    if ([plist isKindOfClass:[NSDictionary class]])
    {
      st = [[ScoreTuple alloc] initWithPropertyList: plist];
      if (st) {
        [stArray addObject:st];
      }
    }
  } // endfor
  
  return stArray;
}




//-------------------------------------- -o-
- (NSString *) description
{
  NSString *output = 
    [NSString stringWithFormat:@"[%ul - %ul - %@", 
      self.score, self.flipsCount, [Zed dateFormatFullShort:self.date]];

  if (self.matchGameType) {
    output = [output stringByAppendingString: 
               [NSString stringWithFormat:@" - %ul", self.matchGameType]];
  }

  return [output stringByAppendingString:@"]"];
}




//-------------------------------------- -o-
// compareScore:
//
// Sort scores from highest to lowest.
//
- (NSComparisonResult) compareScore: (ScoreTuple *) otherTuple
{
  if (self.score > otherTuple.score) {
    return NSOrderedAscending;
  } else if (self.score < otherTuple.score) {
    return NSOrderedDescending;
  } else {
    return NSOrderedSame;
  }
}


//-------------------------------------- -o-
// compareFlipsCount:
//
// Sort flips count from lowest to highest.
//
- (NSComparisonResult) compareFlipsCount: (ScoreTuple *) otherTuple
{
  if (self.flipsCount > otherTuple.flipsCount) {
    return NSOrderedDescending;
  } else if (self.flipsCount < otherTuple.flipsCount) {
    return NSOrderedAscending;
  } else {
    return NSOrderedSame;
  }
}


//-------------------------------------- -o-
// compareDate:
//
// Sort date from most recent to oldest.
//
- (NSComparisonResult) compareDate: (ScoreTuple *) otherTuple
{
  return [otherTuple.date compare:self.date];
}


@end // @implementation ScoreTuple

