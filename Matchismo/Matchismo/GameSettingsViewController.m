//
//  GameSettingsViewController.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "GameSettingsViewController.h"



//---------------------------------------------------- -o-
@interface GameSettingsViewController()

  // sortScoreSegmentAction chooses which element of the score tuple
  //   sorts the list of scores for each game. 
  // clearScoreButton erases all stored scores.
  //
  @property (weak, nonatomic) IBOutlet  UISegmentedControl 
                                                 *sortScoreSegmentOutlet;
  - (IBAction) sortScoreSegmentAction: (id)sender;

  - (IBAction) clearScoreButton: (id)sender;


  // startGameSegmentAction indicates which game (game view) should appear 
  //   to the user first -- Match or Set.
  // If Match Game is chosen, then either 2 or 3 card match is possible.
  //
  @property (weak, nonatomic) IBOutlet  UISegmentedControl 
                                                 *startGameSegmentOutlet;

  - (IBAction) startGameSegmentAction: (id)sender;

  @property (weak, nonatomic) IBOutlet  UILabel  *matchGameTypeLabel;
  @property (weak, nonatomic) IBOutlet  UISegmentedControl 
                                                 *matchGameTypeSegmentOutlet;

  - (IBAction) matchGameTypeSegmentAction: (id)sender;


  // UIStepper chooses how many cards appear when deck is dealt.
  //
  @property (weak, nonatomic) IBOutlet UILabel   *initialMatchCardCountValueLabel;
  @property (weak, nonatomic) IBOutlet UIStepper *initialMatchCardCountStepperOutlet;

  - (IBAction) initialMatchCardCountStepperAction: (UIStepper *)sender;


  //
  - (void) updateUI;

@end



//---------------------------------------------------- -o-
@implementation GameSettingsViewController

//------------------- -o-
// viewDidLoad
//
// UI updates split into initial and variable settings.
// UI subviews in viewDidLoad will be updated directly by the user post-boot.
//
// NB  Check for MATCHGAME_NUMCARDS_DEFAULT occurs in both 
//     GameSettingsViewController and CardGameViewController_v2.
//
- (void) viewDidLoad
{
  [super viewDidLoad];

  //
  self.sortScoreSegmentOutlet.selectedSegmentIndex = 
    [Zed udIntegerGet:SCORE_SORT_ELEMENT dictionaryKey:DICTIONARY_ROOT];

  self.startGameSegmentOutlet.selectedSegmentIndex = 
    [Zed udIntegerGet:START_GAME_TYPE dictionaryKey:DICTIONARY_ROOT];

  self.matchGameTypeSegmentOutlet.selectedSegmentIndex = 
    [Zed udIntegerGet:MATCHGAME_TYPE dictionaryKey:DICTIONARY_ROOT];


  // Match Game card count range is [2,52].
  //
  self.initialMatchCardCountStepperOutlet.minimumValue = MATCHGAME_NUMCARDS_MIN;
  self.initialMatchCardCountStepperOutlet.maximumValue = MATCHGAME_NUMCARDS_MAX;

  NSUInteger matchgameCardCount = 
    [Zed udUIntegerGet:MATCHGAME_NUMCARDS dictionaryKey:DICTIONARY_ROOT];

  self.initialMatchCardCountStepperOutlet.value = 
    (matchgameCardCount >= MATCHGAME_NUMCARDS_MIN) 
      ? matchgameCardCount : MATCHGAME_NUMCARDS_DEFAULT;

  self.initialMatchCardCountValueLabel.text = 
    [NSString stringWithFormat:@"%d", matchgameCardCount];


  //
  [self updateUI];

} // viewDidLoad



//------------------- -o-
- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

#ifdef debug
  [Dump   dict: [Zed udGet:DICTIONARY_ROOT]
    //withHeader: [DICTIONARY_ROOT stringByAppendingString: @" USER DEFAULTS--"]
    withHeader: @"DEFAULTS"
  ];

  //[Dump lp:@"animated" o:@(animated)];
#endif // debug


  // Adapt settings to corner case where the number of cards to be
  // dealt in Match Game is automatically adjusted -- probably because
  // the minimum was raised when switching to a 3-card game.
  //
  NSUInteger  matchgameCardCount = 
    [Zed udUIntegerGet:MATCHGAME_NUMCARDS dictionaryKey:DICTIONARY_ROOT];

  self.initialMatchCardCountValueLabel.text = 
    [NSString stringWithFormat:@"%d", matchgameCardCount];

  self.initialMatchCardCountStepperOutlet.value = matchgameCardCount;

} // viewWillAppear:(BOOL)animated




//------------------- -o-
- (IBAction)sortScoreSegmentAction:(id)sender 
{
  [Zed   udObjectSet: SCORE_SORT_ELEMENT
       dictionaryKey: DICTIONARY_ROOT
              object: @([sender selectedSegmentIndex])];
}


//------------------- -o-
- (IBAction)clearScoreButton:(id)sender 
{
  NSMutableDictionary *dict = [Zed udGet: DICTIONARY_ROOT];

  [dict removeObjectForKey: MATCHGAME_SCORES];
  [dict removeObjectForKey: SETGAME_SCORES];

  [Zed    udSet: DICTIONARY_ROOT
     dictionary: dict];
}


//------------------- -o-
- (IBAction)startGameSegmentAction:(id)sender 
{
  [Zed   udObjectSet: START_GAME_TYPE
       dictionaryKey: DICTIONARY_ROOT
              object: @([sender selectedSegmentIndex])];

  [self updateUI];
}


//------------------- -o-
- (IBAction)matchGameTypeSegmentAction:(id)sender 
{
  [Zed   udObjectSet: MATCHGAME_TYPE
       dictionaryKey: DICTIONARY_ROOT
              object: @([sender selectedSegmentIndex]) ];
}


//------------------- -o-
- (IBAction) initialMatchCardCountStepperAction: (UIStepper *)sender 
{
  NSUInteger  matchgameCardCount = (NSUInteger) sender.value;

  self.initialMatchCardCountValueLabel.text = 
    [NSString stringWithFormat:@"%d", matchgameCardCount];

  [Zed   udObjectSet: MATCHGAME_NUMCARDS
       dictionaryKey: DICTIONARY_ROOT
              object: @(matchgameCardCount) ];
}




//------------------- -o-
// updateUI
//
// Disappear "Start Game Type" label and segment when Set Game is chosen.
//
- (void) updateUI
{
  NSUInteger startGame = 
    [Zed udUIntegerGet:START_GAME_TYPE dictionaryKey:DICTIONARY_ROOT];

  if (GSMatchGame != startGame) {
    self.matchGameTypeLabel.alpha             = 0;
    self.matchGameTypeSegmentOutlet.alpha     = 0;

  } else {
    self.matchGameTypeLabel.alpha             = 1;
    self.matchGameTypeSegmentOutlet.alpha     = 1;
  }

} // updateUI


@end // @implementation GameSettingsViewController

