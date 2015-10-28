//
//  GameScoreViewController.m
//
//
// TBD  Option for 2-player game--
//        . switch on Settings page
//        . begin with player 1
//        . switch players on unsuccessful match, allow any number of flips
//            and successful matches
//        . show split score during 2-player game
//        . incorporate split score into existing tuple format
//        . works for v2 Set and Match games only
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "GameScoreViewController.h"


//---------------------------------------------------- -o-
@interface GameScoreViewController ()

  @property (weak, nonatomic) IBOutlet  UITextView  *matchGameScoreText;
  @property (weak, nonatomic) IBOutlet  UITextView  *setGameScoreText;
  @property (nonatomic)                 SEL          stSelector;

@end



//---------------------------------------------------- -o-
#define GAMESCOREVC_EMPTY         @"\t\t(No scores recorded.)"

#define GAMESCOREVC_HEADER_MATCH  @"SCORE\tFLIPS    DATE\n"
#define GAMESCOREVC_FORMAT_MATCH  @"%d\t\t%d\t      %@   %@\n"

#define GAMESCOREVC_HEADER_SET    GAMESCOREVC_HEADER_MATCH
#define GAMESCOREVC_FORMAT_SET    @"%d\t\t%d\t      %@\n"

#define GAMESCOREVC_SEP           @"_________________________________\n"



//---------------------------------------------------- -o-
@implementation GameScoreViewController

//---------------------- -o-
- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];


  //
  // Establish sort criteria: Sort scores in descending order; 
  //   flips in ascending order; dates in descending order.
  //
  NSUInteger sortField  = 
    [Zed udUIntegerGet:SCORE_SORT_ELEMENT dictionaryKey:DICTIONARY_ROOT];


  // Sort scores in descending order; flips in ascending order; dates
  //   in descending order.
  //
  switch (sortField) 
  {
  case GSSortByScore:
    self.stSelector = @selector(compareScore:);        break;
  case GSSortByFlips:
    self.stSelector = @selector(compareFlipsCount:);   break;
  case GSSortByDate:
    self.stSelector = @selector(compareDate:);         break;
  } 



  // Match game scores.
  //
  NSArray *matchScores =
    [Zed udArrayGet: MATCHGAME_SCORES dictionaryKey: DICTIONARY_ROOT];

  if (!matchScores) {
    self.matchGameScoreText.text = GAMESCOREVC_EMPTY;

  } else {
    NSString  *output = @"";

    output = [output stringByAppendingString: GAMESCOREVC_HEADER_MATCH ];
    output = [output stringByAppendingString: GAMESCOREVC_SEP ];

    for (id obj in 
          [[ScoreTuple arrayFromPropertyList: matchScores] 
                    sortedArrayUsingSelector: self.stSelector] )
    {
      ScoreTuple *st = (ScoreTuple *) obj;

      NSString *typeAndVersion = 
        [NSString stringWithFormat:@"%@%@",
          (GSTwoCardMatch == st.matchGameType) ? @"" : @"T",
          (GSVersionOne   == st.gameVersion)   
	    ? ((GSTwoCardMatch == st.matchGameType) ? @"v1" : @",v1")
	    : @"" ];

      if ([typeAndVersion length] > 0) {
        typeAndVersion = [NSString stringWithFormat:@"(%@)", typeAndVersion];
      }
          
      output = [output stringByAppendingFormat: GAMESCOREVC_FORMAT_MATCH,
                 st.score, st.flipsCount, 
                   [Zed dateFormatFullShort:st.date], typeAndVersion ];
    }

    self.matchGameScoreText.text = output;

  } // endif -- matchScores



  // Set game scores.
  //
  NSArray *setScores = 
    [Zed udArrayGet: SETGAME_SCORES dictionaryKey: DICTIONARY_ROOT];

  if (!setScores) {
    self.setGameScoreText.text = GAMESCOREVC_EMPTY;

  } else {
    NSString  *output = @"";

    output = [output stringByAppendingString: GAMESCOREVC_HEADER_SET ];
    output = [output stringByAppendingString: GAMESCOREVC_SEP ];

    for (id obj in 
          [[ScoreTuple arrayFromPropertyList: setScores] 
                    sortedArrayUsingSelector: self.stSelector] )
    {
      ScoreTuple *st = (ScoreTuple *) obj;

      NSString *typeAndVersion = 
        [NSString stringWithFormat:@"%@",
          (GSVersionOne == st.gameVersion) ? @"v1" : @"" ];

      if ([typeAndVersion length] > 0) {
        typeAndVersion = [NSString stringWithFormat:@"(%@)", typeAndVersion];
      }

      output = [output stringByAppendingFormat: GAMESCOREVC_FORMAT_MATCH,
                 st.score, st.flipsCount, 
                   [Zed dateFormatFullShort:st.date], typeAndVersion ];
    }


    self.setGameScoreText.text = output;

  } // endif -- setScores

} // viewWillAppear:


@end // @implementation GameScoreViewController

