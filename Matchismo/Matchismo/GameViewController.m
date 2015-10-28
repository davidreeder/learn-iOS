//
// GameViewController.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "GameViewController.h"
#import "GameSettingsViewController.h"



//---------------------------------------------------- -o-
@implementation GameViewController

//
// getters/setters
//

//------------------- -o-
- (void) setFlipsCount: (int)flipsCount
{
  _flipsCount = flipsCount;
  self.flipsLabel.text = 
    [NSString stringWithFormat:@"Flips: %d", self.flipsCount];
}


//------------------- -o-
- (void) setCardButtons: (NSArray *)cardButtons
{
  _cardButtons = cardButtons;
}




//---------------------------------------------------- -o-
// class methods
//

//------------------- -o-
// recordCurrentMatchGameScore
//
// Manage memory of game scores in user defaults. 
//
// For this matching game, if current score is defined, append it to the 
// list of all scores and erase the current score.
//
+ (void) recordCurrentMatchGameScore
{
  NSDictionary *matchGameScoreCurrent = 
    [Zed udDictionaryGet:MATCHGAME_SCORE_CURRENT dictionaryKey:DICTIONARY_ROOT];


  if (matchGameScoreCurrent)
  {
    NSMutableArray *matchGameScores = 
      [Zed udArrayGet:MATCHGAME_SCORES dictionaryKey:DICTIONARY_ROOT];

    if (matchGameScores) {
      [matchGameScores addObject: matchGameScoreCurrent];
    } else {
      matchGameScores = (NSMutableArray *) @[ matchGameScoreCurrent ];
    }

    NSMutableDictionary *mdict = [Zed udGet:DICTIONARY_ROOT];

    [mdict setObject: matchGameScores  
              forKey: MATCHGAME_SCORES]; 

    [mdict removeObjectForKey: MATCHGAME_SCORE_CURRENT];

    [Zed      udSet: DICTIONARY_ROOT
         dictionary: mdict];
  }

} // recordCurrentMatchGameScore



//------------------- -o-
// recordCurrentSetGameScore
//
// Manage memory of game scores in user defaults. 
//
// For this matching game, if current score is defined, append it to the 
// list of all scores and erase the current score.
//
+ (void) recordCurrentSetGameScore
{
  NSMutableDictionary *setGameScoreCurrent = 
    [Zed udDictionaryGet: SETGAME_SCORE_CURRENT dictionaryKey: DICTIONARY_ROOT];

  if (setGameScoreCurrent)
  {
    NSMutableArray *setGameScores = 
      [Zed udArrayGet:SETGAME_SCORES dictionaryKey:DICTIONARY_ROOT];

    if (setGameScores) {
      [setGameScores addObject: setGameScoreCurrent];
    } else {
      setGameScores = (NSMutableArray *) @[ setGameScoreCurrent ];
    }

    NSMutableDictionary *mdict = [Zed udGet: DICTIONARY_ROOT];

    [mdict setObject: setGameScores  
              forKey: SETGAME_SCORES]; 

    [mdict removeObjectForKey: SETGAME_SCORE_CURRENT];

    [Zed      udSet: DICTIONARY_ROOT
         dictionary: mdict];
  }

} // recordCurrentSetGameScore




//---------------------------------------------------- -o-
// instance methods
//

//------------------- -o-
- (IBAction) flipCard:(UIButton *)sender
{
  self.flipsCount++;
  self.historyIndex = HISTORY_AT_CURRENT;       
}


//------------------- -o-
// dealAction
//
// Reset flipsCount and history for new game.
//
- (IBAction) dealAction:(UIButton *)sender
{
  self.flipsCount   = 0;
  self.historyIndex = HISTORY_AT_CURRENT; 
}


//------------------- -o-
// sliderAction
//
- (IBAction) sliderAction:(UISlider *)sender 
{
  self.historyIndex = [sender value];   // XXX  coerce float to int 
}


@end // GameViewController -- implementation

