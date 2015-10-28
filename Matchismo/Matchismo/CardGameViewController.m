//
//  CardGameViewController.m
//
//
// NB  Autolayout was applied to all views after they were built.
//     Somehow this compromised the bounds in which the cardback.png is 
//     drawn so it has been omitted.
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "CardGameViewController.h"



//---------------------------------------------------- -o-
@interface CardGameViewController()

  @property (weak, nonatomic)    IBOutlet UISegmentedControl  *segmentSwitch;

#if !defined(TWOCARD_MATCHGAME_ONLY)
  // matchGameType distinguishes between 2- and 3-card Match game.
  //
  @property (nonatomic)                   int                  matchGameType;
#endif

  @property (strong, nonatomic)           CardMatchingGame    *game;

@end



//---------------------------------------------------- -o-
@implementation CardGameViewController

//
// constructors
//

#if defined(TWOCARD_MATCHGAME_ONLY)
//------------------- -o-
- (void) viewDidLoad
{
    [super viewDidLoad];

    // Disable and hide segment switch removing choice between
    //   2- and 3-card Match game.
    //
    self.segmentSwitch.enabled  = NO;
    self.segmentSwitch.alpha    = 0;
}

#else
//------------------- -o-
- (void) viewDidLoad
{
  [super viewDidLoad];

  NSUInteger matchGameType = 
    [Zed udUIntegerGet:MATCHGAME_TYPE dictionaryKey:DICTIONARY_ROOT];


  // Choose match game type from user defaults.
  //
  self.matchGameType = self.segmentSwitch.selectedSegmentIndex = matchGameType;


  // Resets deck once game type is known.  XXX
  //
  self.game = nil;  


  [self updateUI];

} // viewDidLoad
#endif // TWOCARD_MATCHGAME_ONLY




//---------------------------------------------------- -o-
// getters/setters
//

//------------------- -o-
- (void) setCardButtons: (NSArray *)cardButtons
{
  [super setCardButtons:cardButtons];
  [self updateUI];
}


//------------------- -o-
// game
//
// If game property is undefined, instantiate as appropriate with a
//   2-card or 3-card match game. 
//
- (CardMatchingGame *) game
{
  if (!_game) 
  { 
#if !defined(TWOCARD_MATCHGAME_ONLY)
    if (GSTwoCardMatch == self.matchGameType)
    {
#endif
      _game = [[CardMatchingGame alloc] 
                  initWithCardCount: self.cardButtons.count
                          usingDeck: [[PlayingCardDeck alloc] init]
                           flipCost: 1
                    mismatchPenalty: 2 ];

#if !defined(TWOCARD_MATCHGAME_ONLY)
    } else {
      _game = (CardMatchingGame *) [[CardMatchingGameThree alloc] 
                  initWithCardCount: self.cardButtons.count
                          usingDeck: [[PlayingCardDeck alloc] init]
                           flipCost: 1
                    mismatchPenalty: 2 ];
    }
#endif

  } // endif -- !_game

  return _game;
}



//---------------------------------------------------- -o-
// methods
//

//------------------- -o-
- (IBAction) flipCard:(UIButton *)sender
{
  [super flipCard:sender];

  [self.game flipCardAtIndex:[self.cardButtons indexOfObject:sender]];
  [self updateUI];
}


//------------------- -o-
// dealAction
//
// Release the game controller object then refresh the UI.  
// The refresh will allocate a new game in which all data is initialized 
//   by definition.
// Dealing indicates the end of a game, so save current score in list of
//   all scores for this card matching game.
//
- (IBAction) dealAction:(UIButton *)sender
{
  [super dealAction:sender];

  [GameViewController recordCurrentMatchGameScore];

  self.game = nil;
  [self updateUI];
}



//------------------- -o-
- (IBAction) sliderAction:(UISlider *)sender 
{
  [super sliderAction:sender];

  if ([self.game.actionHistory count] == self.historyIndex) {
    self.historyIndex = HISTORY_AT_CURRENT;
  }

  [self updateUI];
}



#if !defined(TWOCARD_MATCHGAME_ONLY)
//------------------- -o-
// segmentAction
//
// Switch between two different types of card matching games.
//
- (IBAction) segmentAction:(UISegmentedControl *)sender
{
  if (GSTwoCardMatch == [sender selectedSegmentIndex]) 
  {
    //[Log infoMsg:@"Initialize game: Two-card matching."];
    self.matchGameType = GSTwoCardMatch;

  } else {
    //[Log infoMsg:@"Initialize game: Three-card matching."];
    self.matchGameType = GSThreeCardMatch;
  }

  self.game = nil;      // Force game to reinitialize.

  [self updateUI];
}
#endif // !TWOCARD_MATCHGAME_ONLY




//------------------- -o-
- (void) updateUI
{
  //UIImage  *cardback  = [UIImage imageNamed:@"cardback.png"];
  UIImage  *cardback  = nil;
    // NB TBD  cardback stopped rendering within proper bounds for all
    //         cards after Autolayout was switched on.  ??

#ifdef debug
  NSString *deckstr   = @"DECKSTATUS... ";  // DEBUG
#endif


  // Update all buttons per game model.
  //
  for (UIButton *cardButton in self.cardButtons)
  {
    Card *card = 
            [self.game cardAtIndex:[self.cardButtons indexOfObject:cardButton]];

#ifdef debug
    deckstr = [NSString stringWithFormat:@"%@ %@%@",                    // DEBUG
        deckstr, card.contents, (card.isUnplayable ? @"X" : @"_") ];
#endif

    [cardButton setTitle:card.contents forState:UIControlStateSelected];
    [cardButton setTitle:card.contents forState:UIControlStateSelected|UIControlStateDisabled];

    cardButton.selected  = card.isFaceUp;
    cardButton.enabled   = !card.isUnplayable;
    cardButton.alpha     = card.isUnplayable ? 0.3 : 1.0;


    if (cardButton.selected) {
      [cardButton setImage:nil forState:UIControlStateNormal];

    } else {
      [cardButton setImage:cardback forState:UIControlStateNormal];
      cardButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 3, 2);
    }
  } // endfor



  // Post score to view.
  // Update MATCHGAME_SCORE_CURRENT.
  //
  self.scoreLabel.text 
            = [NSString stringWithFormat:@"Score:\n%d", self.game.score];

  ScoreTuple *st = 
    [[ScoreTuple alloc] initWithScore: self.game.score 
                           flipsCount: self.flipsCount
                                 date: [NSDate date]
			  gameVersion: GSVersionOne
			matchGameType: self.matchGameType];

  [Zed   udObjectSet: MATCHGAME_SCORE_CURRENT
       dictionaryKey: DICTIONARY_ROOT
              object: [st propertyListValue] ];


  
  // Handle descriptionLabel of last move or history of moves in view.
  //   . Update slider size
  //   . At beginning: post game type
  //   . Otherwise post last move, unless instructed to...
  //   . Post previous history item
  //
  if (0 == self.flipsCount) 
  {
#if !defined(TWOCARD_MATCHGAME_ONLY)
    if (GSTwoCardMatch == self.matchGameType ) 
    {
#endif
      self.descriptionLabel.text = @"☁ TWO-CARD MATCH ☁";

#if !defined(TWOCARD_MATCHGAME_ONLY)
    } else {
      self.descriptionLabel.text = @"☁ THREE-CARD MATCH ☁";
    }
#endif

  } else {
    if (HISTORY_AT_CURRENT == self.historyIndex) {
      self.historySlider.maximumValue = [self.game.actionHistory count];
      self.historySlider.value        = self.historySlider.maximumValue;

      self.descriptionLabel.text  = self.game.action;
      self.descriptionLabel.alpha = ALPHA_OFF;

    } else {
      self.descriptionLabel.text = self.game.actionHistory[self.historyIndex];
      self.descriptionLabel.alpha = ALPHA_GREY;
    }
  }


  // Disable segmentSwitch during game play.
  // Make it disabled and invisible when it is not implemented.
  //

#if !defined(TWOCARD_MATCHGAME_ONLY)
  if (0 == self.flipsCount) 
  {
    self.segmentSwitch.enabled  = YES;
    self.segmentSwitch.alpha    = 1.0;

  } else {
    self.segmentSwitch.enabled  = NO;
    self.segmentSwitch.alpha    = 0.3;
  }

#else
    self.segmentSwitch.enabled  = NO;
    self.segmentSwitch.alpha    = 0;
#endif


#ifdef debug
  [Dump objs:@[deckstr]];         // DEBUG
#endif

} // updateUI


@end // @implementation CardGameViewController

