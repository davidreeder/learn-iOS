//
//  SetGameViewController.m
//
// NB  Autolayout was applied after all the views were completed.
//     Somehow this compromises the bounds of the lower six cards
//     such that three character NSAttributedStrings are no longer 
//     wrapped across two lines.  As a quick cleanup, these six cards
//     are configured to clip subviews.
//     
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "SetGameViewController.h"



//---------------------------------------------------- -o-
#define CARDBUTTON_BACKGROUND_COLOR_UNSELECTED \
                        [[UIColor orangeColor] colorWithAlphaComponent:0.2];

@interface SetGameViewController ()

  @property (strong, nonatomic)  CardMatchingGame  *game;

@end



//---------------------------------------------------- -o-
@implementation SetGameViewController

//
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
- (CardMatchingGame *) game
{
  if (!_game) 
  { 
    _game = [[CardMatchingGameThree alloc] 
                initWithCardCount: self.cardButtons.count
                        usingDeck: [[SetCardDeck alloc] init]
                         flipCost: 2
                  mismatchPenalty: 7 
            ]; 
  }

  return _game;
}




//---------------------------------------------------- -o-
// methods
//

- (void) viewDidLoad
{
  [super viewDidLoad];

  for (UIButton *cardButton in self.cardButtons) {
    cardButton.backgroundColor = CARDBUTTON_BACKGROUND_COLOR_UNSELECTED;
  }
}


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
  
  [GameViewController recordCurrentSetGameScore];

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



//------------------- -o-
// updateUI
//
// Card semantics--
//   unplayable  :: disabled, invisible (alpha=0)
//   faceUp      :: highlighted background
//
- (void) updateUI
{
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
    deckstr = [NSString stringWithFormat:@"%@ %@%@",    // DEBUG
        deckstr, [card description], (card.isUnplayable ? @"X" : @"_") ];
#endif

    cardButton.titleLabel.textAlignment = NSTextAlignmentCenter;

    [cardButton 
      setAttributedTitle: [(SetCard *)card descriptionWithAttributedString]
                forState: UIControlStateNormal];

    [cardButton 
      setAttributedTitle: [(SetCard *)card descriptionWithAttributedString]
                forState: UIControlStateSelected];

#ifdef debugNOT
    [Dump strAttr: [(SetCard *)card descriptionWithAttributedString]];
#endif

    cardButton.selected  = card.isFaceUp;
    cardButton.enabled   = !card.isUnplayable;
    cardButton.alpha     = card.isUnplayable ? 0 : 1;


    if (cardButton.selected) {
      cardButton.backgroundColor = 
        [[UIColor magentaColor] colorWithAlphaComponent:0.5];

    } else {
      cardButton.backgroundColor = CARDBUTTON_BACKGROUND_COLOR_UNSELECTED;
    }
  }



  // Post score to view.
  // Update SETGAME_SCORE_CURRENT.
  //
  self.scoreLabel.text 
            = [NSString stringWithFormat:@"Score: %d", self.game.score];

  ScoreTuple *st = 
    [[ScoreTuple alloc] initWithScore: self.game.score
                           flipsCount: self.flipsCount
                                 date: [NSDate date]
                          gameVersion: GSVersionOne
                        matchGameType: nil];

  [Zed   udObjectSet: SETGAME_SCORE_CURRENT
       dictionaryKey: DICTIONARY_ROOT
              object: [st propertyListValue] ];


  
  // Handle descriptionLabel of last move or history of moves in view.
  //   . At beginning: post game type
  //   . Update slider size
  //   . And post last move, unless instructed to...
  //   . Post previous history item
  //
  if (0 == self.flipsCount) {
      self.descriptionLabel.text = @"☁ SET MATCH ☁";

  } else {
    if (HISTORY_AT_CURRENT == self.historyIndex) {
      self.historySlider.maximumValue = [self.game.actionHistory count];
      self.historySlider.value = self.historySlider.maximumValue;

      self.descriptionLabel.attributedText = 
        [SetCardDeck convertToAttributedString: self.game.action
                                      withDeck: (SetCardDeck *)self.game.deck ];

      self.descriptionLabel.alpha = ALPHA_OFF;

    } else {
      self.descriptionLabel.attributedText = 
        [SetCardDeck 
          convertToAttributedString: self.game.actionHistory[self.historyIndex]
                           withDeck: (SetCardDeck *)self.game.deck ];

      self.descriptionLabel.alpha = ALPHA_GREY;
    }
  }


#ifdef debug
  [Dump objs:@[deckstr]];         // DEBUG
#endif

} // updateUI


@end // @implementation SetGameViewController

