//
// GameViewController_v2.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "GameViewController_v2.h"
#import "GameSettingsViewController.h"



//---------------------------------------------------- -o-
@implementation GameViewController_v2

//------------------- -o-
- (void) viewDidLoad
{
  [super viewDidLoad];

  self.historySlider.value = self.historySlider.maximumValue;

  [self updateUI];
}


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

//----------------- -o-
// flipCardWithGesture: 
//
// NB  Test for indexPath section to ignore taps on passive
//     cells in additional UICollectionView sections.
//
- (IBAction) flipCardWithGesture: (UITapGestureRecognizer *)gesture
{
  CGPoint       tapLocation = [gesture locationInView:self.cardCollectionView];
  NSIndexPath  *indexPath   = 
    [self.cardCollectionView indexPathForItemAtPoint:tapLocation];

  if (indexPath && (0 == indexPath.section))
  {
    self.flipsCount++;
    self.historyIndex = HISTORY_AT_CURRENT;

    [self.game flipCardAtIndex:indexPath.item];
    [self updateUI];
  }
}



//------------------- -o-
// dealAction
//
// Reset flipsCount and history for new game.
// Release the game controller object then refresh the UI.  
// The refresh will allocate a new game in which all data is initialized 
//   by definition.
// Dealing indicates the end of a game, so save current score in list of
//   all scores for this card matching game.
//
// NB XXX  Each subclass must extend dealAction to call updateUI!
//
- (IBAction) dealAction:(UIButton *)sender
{
  self.flipsCount = 0;

  self.historySlider.value = self.historySlider.maximumValue = 1;
  self.historyIndex = HISTORY_AT_CURRENT;

  [GameViewController_v2 recordCurrentMatchGameScore];
  [GameViewController_v2 recordCurrentSetGameScore];

  self.game = nil;
}


//------------------- -o-
// sliderAction:
//
- (IBAction) sliderAction:(UISlider *)sender 
{
  self.historyIndex = [sender value];   // XXX  coerce float to int 

  if ([self.game.actionHistory count] == self.historyIndex) {
    self.historyIndex = HISTORY_AT_CURRENT;
  }

  [self updateUI];
}


//------------------- -o-
- (void) updateUI
{
  // ABSTRACT
}



//---------------------------------------------------- -o-
// Protocol UICollectionViewDataSource 
//

//------------------- -o-
- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
  return 1;
}


//------------------- -o-
// collectionView:numberOfItemsInSection:                       // ABSTRACT
//
- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger)          section
{
  return -1;                                             
}


//------------------- -o-
- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *)      indexPath
{
  UICollectionViewCell *cell = 
    [collectionView dequeueReusableCellWithReuseIdentifier: @"PlayingCard" 
                                              forIndexPath: indexPath];

  Card *card = [self.game cardAtIndex:indexPath.item];
  [self updateCell:cell usingCard:card];

  return cell;
}


//------------------- -o-
- (void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card
{
  return;                                                       // ABSTRACT
}


@end // @implementation GameViewController_v2 

