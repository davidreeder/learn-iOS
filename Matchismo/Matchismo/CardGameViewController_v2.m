//
//  CardGameViewController_v2.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "CardGameViewController_v2.h"



//---------------------------------------------------- -o-
@interface CardGameViewController_v2()

  @property (weak, nonatomic)  IBOutlet UISegmentedControl  *segmentSwitch;

  @property (nonatomic)                 NSUInteger           initialMatchCardCount;
      // Number of cards to deal.

  - (void) rebuildCollection;

@end



//---------------------------------------------------- -o-
@implementation CardGameViewController_v2

  @synthesize  game = _game;


//
// constructors
//

//------------------- -o-
- (void) viewDidLoad
{
  [super viewDidLoad];


#if defined(TWOCARD_MATCHGAME_ONLY)
  // Disable and hide segment switch removing choice between
  //   2- and 3-card Match game.
  //
  self.segmentSwitch.enabled  = NO;
  self.segmentSwitch.alpha    = 0;

#else
  // Choose match game type from user defaults
  //
  NSUInteger matchGameType = 
    [Zed udUIntegerGet:MATCHGAME_TYPE dictionaryKey:DICTIONARY_ROOT];

  self.matchGameType = self.segmentSwitch.selectedSegmentIndex = matchGameType;
  self.game = nil;
#endif // TWOCARD_MATCHGAME_ONLY


  // Place a slight border between card edges and collection view edges.
  // Widen the border on the right side where the scroll bar appears.
  //
  UICollectionViewFlowLayout *flowLayout = 
    (UICollectionViewFlowLayout *) self.cardCollectionView.collectionViewLayout;

  flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 15, 5);


  [self updateUI];

} // viewDidLoad



//------------------- -o-
// viewWillAppear:
//
// Negotiate changes between view and controller regarding number of cards 
//   available for a hand.
//
- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  [self rebuildCollection];

} // viewWillAppear:




//---------------------------------------------------- -o-
// getters/setters
//

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
    // Define game with a given deck of cards.
    //
#if !defined(TWOCARD_MATCHGAME_ONLY)
    if (GSTwoCardMatch == self.matchGameType)
    {
#endif
      _game = [[CardMatchingGame alloc] 
                  initWithCardCount: self.initialMatchCardCount
                          usingDeck: [[PlayingCardDeck alloc] init]
                           flipCost: 1
                    mismatchPenalty: 2 ];

#if !defined(TWOCARD_MATCHGAME_ONLY)
    } else {
      _game = (CardMatchingGame *) [[CardMatchingGameThree alloc] 
                  initWithCardCount: self.initialMatchCardCount
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
- (IBAction) dealAction:(UIButton *)sender
{
  [super dealAction:sender];

  self.initialMatchCardCount = 0;

  [self rebuildCollection];
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
// initialMatchCardCount
//
// Determine how many cards to deal.
//
// ASSUME  Bounds of initialMatchCardCount are guarded by the min/max settings
//         on GameSettingsViewController::initialMatchCardCountStepperOutlet.
//
// NB  Check for MATCHGAME_NUMCARDS_DEFAULT occurs in both 
//     GameSettingsViewController and CardGameViewController_v2.
//
- (NSUInteger) initialMatchCardCount
{
  if (_initialMatchCardCount <= 0) 
  {
    _initialMatchCardCount = 
      [Zed udUIntegerGet:MATCHGAME_NUMCARDS dictionaryKey:DICTIONARY_ROOT];

    NSUInteger mincards = 
         (GSTwoCardMatch == self.matchGameType) 
           ? MATCHGAME_NUMCARDS_MIN : (MATCHGAME_NUMCARDS_MIN+1);


    // Catch corner-cases: 
    //   1) First run with empty user defaults dictionary;
    //   2) Minimum number of cards is set, but 3-card match game is chosen.
    //
    if (_initialMatchCardCount <= 0) {
      _initialMatchCardCount = MATCHGAME_NUMCARDS_DEFAULT;

    } else if (_initialMatchCardCount < mincards) {
      _initialMatchCardCount = mincards; 
    }

    [Zed   udObjectSet: MATCHGAME_NUMCARDS 
         dictionaryKey: DICTIONARY_ROOT
                object: @(_initialMatchCardCount) ];
  }

  return _initialMatchCardCount;
}



//------------------- -o-
- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger)          section
{
  return self.initialMatchCardCount;
}



//------------------- -o-
// updateCell:usingCard:
//
// Adapted directly from P.Hegarty "PlayingCardGameViewController.m"
//   (sans animation).
//
// Identify the instance of MatchCardView view from cell and assign
// it the values of its counterpart PlayingCard in the model.
// The details of the model are fully realized in this card when the 
// MatchCardView is redrawn when the OS invokes drawRect:.
// 

typedef enum { 
  UCFlip, UCFlipThenDissolve, UCWaitThenDissolve, UCNone
} UCAnimationType;


- (void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card
{
  //
  if ([cell isKindOfClass:[GameCollectionViewCell class]]) 
  {
    MatchCardView  *matchCardView = 
      ((GameCollectionViewCell *) cell).matchCardView;


    if ([card isKindOfClass:[PlayingCard class]]) 
    {
      PlayingCard  *playingCard = (PlayingCard *)card;

      NSIndexPath  *cardIndex =
                      [self.cardCollectionView indexPathForCell:cell];
                      // NB  cardIndex is nil in the absence of a selection.

      BOOL  isChanged = (matchCardView.isFaceUp != playingCard.isFaceUp);

      UCAnimationType  animaType      = UCNone;
      NSTimeInterval   blockDuration  = 0.35;  
          // Duration in seconds of each animation block.


#ifdef debug
[Dump objs:@[ 
    @"  ENTRY", [card description], @"at", 
    [NSString stringWithFormat:@"%@", (cardIndex) ? @(cardIndex.item) : @"NIL"],
    [NSString stringWithFormat:@":: MCV %@   PC %@ %@", 
      (matchCardView.isFaceUp) ? @"U" : @"d", 
      (playingCard.isFaceUp)   ? @"U" : @"d", (playingCard.isUnplayable)   ? @"X" : @"_"],
    [NSString stringWithFormat:@"%@", isChanged ? @"CHANGED" : @""]
] ];
#endif


      // Determine animations based upon previous state amongst visible
      //   cells and card view collection indices.
      //
      if (!cardIndex) {         // Nothing is selected -- no animations.
        animaType = UCNone;

      } else {
        if (playingCard.isUnplayable) 
                                // Unplayable bit indicates match is found, 
                                //   -or- card was previously matched.
        {
          if (isChanged) {      // Matching card is flipped.
            animaType = UCFlipThenDissolve;


          } else if (playingCard.isFaceUp) {    
                                // Matching card is already face up.
            animaType = UCWaitThenDissolve;
          } // endif -- isChanged


        } else {
	  matchCardView.alpha = ALPHA_OFF;

	  if (isChanged) { // Flipped a card that does not match
			   //   -or-  conceal non-matching card.
	    animaType = UCFlip;

	  } else {                // No change to playing card.
	    animaType = UCNone;
	  }

        } // endif -- playingCard.isUnplayable
      } // endif -- !cardIndex



      // Animation transitions by type.
      //
      switch (animaType) 
      {
      case UCNone:
        {
          matchCardView.rank    = playingCard.rank;
          matchCardView.suit    = playingCard.suit;
          matchCardView.faceUp  = playingCard.isFaceUp;
          matchCardView.alpha   = playingCard.isUnplayable ? ALPHA_DISABLED : ALPHA_OFF;
        }
        break;

      case UCFlip:
        {
          [UIView transitionWithView: matchCardView
                            duration: blockDuration
                             options: UIViewAnimationOptionTransitionFlipFromBottom
                          animations: ^{
                            matchCardView.rank    = playingCard.rank;
                            matchCardView.suit    = playingCard.suit;
                            matchCardView.faceUp  = playingCard.isFaceUp;
                            //matchCardView.alpha   = playingCard.isUnplayable ? ALPHA_DISABLED : ALPHA_OFF;
                          }
                          completion: nil
          ];
        }
        break;

      case UCFlipThenDissolve:
        {
          [UIView transitionWithView: matchCardView
                            duration: blockDuration
                             options: UIViewAnimationOptionTransitionFlipFromBottom
                          animations: ^{
                            matchCardView.rank    = playingCard.rank;
                            matchCardView.suit    = playingCard.suit;
                            matchCardView.faceUp  = playingCard.isFaceUp;
                            //matchCardView.alpha   = playingCard.isUnplayable ? ALPHA_DISABLED : ALPHA_OFF;
                          }
                          completion: ^(BOOL finished) {
                            if (!finished)  { return; }
                            [UIView transitionWithView: matchCardView
                                              duration: blockDuration
                                               options: UIViewAnimationOptionTransitionCrossDissolve   
                                            animations: ^{
                                              matchCardView.rank    = playingCard.rank;
                                              matchCardView.suit    = playingCard.suit;
                                              matchCardView.faceUp  = playingCard.isFaceUp;
                                              matchCardView.alpha   = playingCard.isUnplayable ? ALPHA_DISABLED : ALPHA_OFF;
                                            }
                                            completion: nil
                            ];
                          }
          ];
        }
        break;

      case UCWaitThenDissolve:
        {
          [UIView transitionWithView: matchCardView
                            duration: blockDuration
                             options: UIViewAnimationOptionTransitionCrossDissolve   
                          animations: ^{ /*EMPTY*/ }          
                          completion: ^(BOOL finished) {
                            if (!finished)  { return; }
                            [UIView transitionWithView: matchCardView
                                              duration: blockDuration
                                               options: UIViewAnimationOptionTransitionCrossDissolve   
                                            animations: ^{
                                              matchCardView.rank    = playingCard.rank;
                                              matchCardView.suit    = playingCard.suit;
                                              matchCardView.faceUp  = playingCard.isFaceUp;
                                              matchCardView.alpha   = playingCard.isUnplayable ? ALPHA_DISABLED : ALPHA_OFF;
                                            }
                                            completion: nil
                            ];
                          }
          ];
        }
        break;

      } // endswitch
      
    } // endif -- isKindOfClass: PlayingCard
  } // endif -- isKindOfClass: GameCollectionViewCell 

} // updateCell:usingCard:




//------------------- -o-
// rebuildCollection
//
// Test difference between number of items in UICollectionView
// section zero (0) and the initialMatchCardCount.  Insert or delete
// UICollectionViewCell views as necessary.
//
// ASSUME  There is only one section, at index 0!
//
- (void) rebuildCollection
{
  NSUInteger       sectionNumber = 0;
  NSUInteger       numItemsInSection = 
                     [self.cardCollectionView 
                       numberOfItemsInSection:sectionNumber];
  NSMutableArray  *indexPathArray = [[NSMutableArray alloc] init];

         
  //
  if (numItemsInSection < self.initialMatchCardCount) 
  {
    for (NSUInteger i = numItemsInSection; i < self.initialMatchCardCount; i++) {
      [indexPathArray addObject: 
        [NSIndexPath indexPathForRow:i inSection:sectionNumber]];
    }

    [self.cardCollectionView insertItemsAtIndexPaths:indexPathArray];


  //
  } else if (numItemsInSection > self.initialMatchCardCount) {
    for (NSUInteger i = self.initialMatchCardCount; i < numItemsInSection; i++)
    {
      [indexPathArray addObject:
        [NSIndexPath indexPathForRow:i inSection:sectionNumber]];
    }

    [self.cardCollectionView deleteItemsAtIndexPaths:indexPathArray];

  } // endif

} // rebuildCollection



//------------------- -o-
- (void) updateUI
{
  // Update visible cells. 
  //
  for (UICollectionViewCell *cell in [self.cardCollectionView visibleCells]) 
  {
    NSIndexPath *indexPath  = [self.cardCollectionView indexPathForCell:cell];
    Card        *card       = [self.game cardAtIndex:indexPath.item];

    [self updateCell:cell usingCard:card];
  }


  // Post score to view.
  // Update MATCHGAME_SCORE_CURRENT.
  //
  self.scoreLabel.text 
            = [NSString stringWithFormat:@"Score: %d", self.game.score];

  ScoreTuple *st = 
    [[ScoreTuple alloc] initWithScore: self.game.score 
                           flipsCount: self.flipsCount
                                 date: [NSDate date]
                          gameVersion: GSVersionTwo
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

    self.descriptionLabel.alpha = ALPHA_OFF;

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
    self.segmentSwitch.alpha    = ALPHA_OFF;

  } else {
    self.segmentSwitch.enabled  = NO;
    self.segmentSwitch.alpha    = ALPHA_DISABLED;
  }

#else
    self.segmentSwitch.enabled  = NO;
    self.segmentSwitch.alpha    = 0;
#endif


  // Verbose output of entire deck.
  //
#ifdef debug
  NSString *deckstr = @"DECKSTATUS... ";  

  for (int i = 0; i < self.initialMatchCardCount; i++) 
  {
    Card *card = [self.game cardAtIndex:i];
    deckstr = [NSString stringWithFormat:@"%@ %@%@",                    
        deckstr, card.contents, (card.isUnplayable ? @"X" : @"_") ];
  }

  [Dump o:deckstr]; 
#endif

} // updateUI


@end // @implementation CardGameViewController_v2

