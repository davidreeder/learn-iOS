//
//  SetGameViewController_v2.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "SetGameViewController_v2.h"



//---------------------------------------------------- -o--
@interface SetGameViewController_v2()

  @property (strong, nonatomic)  CardMatchingGame    *game;
      // Model for Set Match game.

  @property (nonatomic)          NSUInteger           gNumberOfSections;
      // Track the number of UICollectionView sections as game unfolds.  


  //
  - (IBAction) dealAdditionalCardsButtonAction: (UIButton *)sender;
  - (IBAction) hintButtonAction:                (UIButton *)sender;

  - (void) rebuildCollection;

  - (void)   updateCell: (UICollectionViewCell *)cell  
      usingDiscardGroup: (NSArray *)group;

@end



//---------------------------------------------------- -o--
#define SECTION_ZERO  0
#define SECTION_ONE   1

#define INITIAL_CARD_COUNT     12
#define ADDITIONAL_CARD_COUNT  3

#define ADDITIONAL_CARDS_PENALTY  -1
#define HINT_SEARCH_PENALTY       -24

#define CELLSIZE_SETCARD       CGSizeMake(60, 80)
#define CELLSIZE_DISCARDGROUP  CGSizeMake(120, 58)



//---------------------------------------------------- -o--
@implementation SetGameViewController_v2

  @synthesize game = _game;


//
// getters/setters
//

//------------------- -o-
// game
//
- (CardMatchingGame *) game
{
  if (!_game) 
  { 
    _game = [[CardMatchingGameThree alloc] 
                initWithCardCount: INITIAL_CARD_COUNT
                        usingDeck: [[SetCardDeck_v2 alloc] init]
                         flipCost: 2
                  mismatchPenalty: 7 
            ]; 
  }

  return _game;
}




//---------------------------------------------------- -o--
// UICollectionViewDataSource and UICollectionViewDelegateFlowLayout protocol.
//

//------------------- -o-
- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
  return self.gNumberOfSections;
}


//------------------- -o-
- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger)          section
{

  if (SECTION_ZERO == section) {
    return [self.game.cards count];

  } else {                              // ASSUME SECTION_ONE
    return [self.game deckSizeOfDiscardPile];
  }

} // collectionView:numberOfItemsInSection: 



//------------------- -o-
// collectionView:cellForItemAtIndexPath: 
//
// NB  Overloaded for Set Match game to handle multiple sections with
//     different cell view types.
//
- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *)      indexPath
{
  UICollectionViewCell *cell = nil;

  if (SECTION_ZERO == indexPath.section) {
    cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"PlayingCard" 
                                                     forIndexPath: indexPath];
    Card *card = [self.game cardAtIndex:indexPath.item];
    [self updateCell:cell usingCard:card];

  } else {                                      // ASSUME SECTION_ONE
    if ([self.cardCollectionView numberOfItemsInSection:indexPath.section] > 0)
    {
      cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"DiscardGrouping" 
                                                       forIndexPath: indexPath];
      NSArray *group = [self.game discardGroupAtIndex:indexPath.item];
      [self updateCell:cell usingDiscardGroup:group];
    }
  }

  return cell;

} // collectionView:cellForItemAtIndexPath: 



//------------------- -o-
// collectionView:viewForSupplementaryElementOfKind:atIndexPath:
//
// Populate content of Headers and Footers across all sections
// to convey a unified message about gameplay.
//
- (UICollectionReusableView *) collectionView: (UICollectionView *)collectionView
            viewForSupplementaryElementOfKind: (NSString *)kind
                                  atIndexPath: (NSIndexPath *)indexPath 
{
  BOOL  isHeader = NO, 
        isFooter = NO;

  if ([kind isEqual:UICollectionElementKindSectionHeader])  { isHeader = YES; }
  if ([kind isEqual:UICollectionElementKindSectionFooter])  { isFooter = YES; }

  if (! (isHeader || isFooter))  { return nil; }


  SectionTitleView  *sectionTitle = 
    [self.cardCollectionView 
      dequeueReusableSupplementaryViewOfKind: kind
                         withReuseIdentifier: isHeader ? @"SectionHeader" : @"SectionFooter"
                                forIndexPath: indexPath ];

  //
  if (0 == indexPath.section) {
    sectionTitle.text = @"";

  } else {                      // ASSUME SECTION_ONE
    if (isHeader) {
      sectionTitle.text = @"Previous Matches";
    } else {
      sectionTitle.text = @"";
    }
  }


  return sectionTitle;

} // collectionView:viewForSupplementaryElementOfKind:atIndexPath:



//------------------- -o-
// collectionView:layout:sizeForItemAtIndexPath:
//
// NB  From UICollectionViewDelegateFlowLayout Protocol 
//     in UICollectionViewDelegate.
//
- (CGSize) collectionView: (UICollectionView *)      collectionView 
                   layout: (UICollectionViewLayout*) collectionViewLayout 
   sizeForItemAtIndexPath: (NSIndexPath *)           indexPath
{
  CGSize cellSize;

  if (SECTION_ONE == indexPath.section) {
    cellSize = CELLSIZE_DISCARDGROUP;

  } else {              // ASSUME SECTION_ZERO
    cellSize = CELLSIZE_SETCARD;
  }

  return cellSize;

} // collectionView:layout:sizeForItemAtIndexPath:




//---------------------------------------------------- -o--
// lifecycle, interface
//

//------------------- -o-
- (void) viewDidLoad
{
  [super viewDidLoad];


  // Initially only one section.
  // Second section added to display discarded matches.
  //
  self.gNumberOfSections = 1;


  // Manage history slider state.
  // NB  Must set because "uninitialized value" is not zero.
  //
  self.historyIndex = HISTORY_AT_CURRENT;


  // Place a slight border between card edges and collection view edges.
  // Widen the border on the right side where the scroll bar appears.
  //
  UICollectionViewFlowLayout *flowLayout = 
    (UICollectionViewFlowLayout *) self.cardCollectionView.collectionViewLayout;

  flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 15);

} // viewDidLoad



//------------------- -o-
- (IBAction) dealAction:(UIButton *)sender
{
  [super dealAction:sender];

  [self rebuildCollection];
  [self updateUI];
}



//------------------- -o-
// dealAdditionalCardsButtonAction:
//
// Randomly choose three cards from the deck and add them to the view.
// Penalize the user if there were matches present in the active deck.
//
// ASSUME  Deck size is a multiple of three. 
//
- (IBAction) dealAdditionalCardsButtonAction: (UIButton *)sender 
{
  // Do nothing if deck is exhausted.
  // NB  updateUI should prevent this from ever happening.
  //
  if ([self.game deckSize] <= 0)  { return; }


  // Check active deck for matches.
  //
  BOOL  activeDeckContainsMatch =
          [(CardMatchingGameThree *)self.game findRandomMatchWithEnableHint:NO];


  // Draw cards from deck.
  // Add to active deck.
  // Generate indexPath data for next step.
  //
  NSUInteger       numItemsInSection = 
                     [self.cardCollectionView numberOfItemsInSection:SECTION_ZERO];
  NSMutableArray  *indexPathList = [[NSMutableArray alloc] init];

  for (int i = 0; i < ADDITIONAL_CARD_COUNT; i++)
  {
    Card *card = [self.game drawRandomCard];

    if (!card) {  // XXX  Should throw exception.
      [Log errorMsg:
        [NSString stringWithFormat:@"%@::dealAdditionalCardsButtonAction: -- ABORT: Drew only %d card(s).", 
          [self class], i ]
      ];
      return; 
    }

    [self.game.cards addObject:card];
    [indexPathList addObject:
      [NSIndexPath indexPathForRow:(numItemsInSection + i) inSection:SECTION_ZERO]];
  }


  // Register new cards in UICollectionView.
  // Post user feedback in status window.
  // Update the UI.
  //
  if ([indexPathList count] > 0) 
  {
    [self.cardCollectionView insertItemsAtIndexPaths:indexPathList];

    if (activeDeckContainsMatch) {
      [self.game userMessage:
        [NSString stringWithFormat:@"Add cards, despite match(es).  Penalty %d.",
          abs(ADDITIONAL_CARDS_PENALTY) ]
      ];
      [self.game updateScore:ADDITIONAL_CARDS_PENALTY];

    } else {
      [self.game userMessage:@"Added three cards."];
    }
  }


  self.historyIndex = HISTORY_AT_CURRENT;
  [self updateUI];

} // dealAdditionalCardsButtonAction:



//------------------- -o-
// hintButtonAction: 
//
// Highlight a randomly selected match in deck and penalize
// the user, unless there are no matches and the deck has been
// exhausted.
//
- (IBAction) hintButtonAction: (UIButton *)sender 
{
  BOOL  activeDeckContainsMatch =
    [(CardMatchingGameThree *)self.game findRandomMatchWithEnableHint:YES];

  if (!activeDeckContainsMatch && ([self.game deckSize] <= 0)) {
    [self.game userMessage: [NSString stringWithFormat:@"Game complete!"]];

  } else {
    [self.game userMessage:
      [NSString stringWithFormat:@"Hint requested.  Penalty %d.",
        abs(HINT_SEARCH_PENALTY) ]
    ];

    [self.game updateScore:HINT_SEARCH_PENALTY];
  }

  self.historyIndex = HISTORY_AT_CURRENT;
  [self updateUI];
}



//------------------- -o-
// rebuildCollection
//
// Add or subtract items to UICollectionView when the deck is re-dealt.
//
- (void) rebuildCollection
{
  NSUInteger  numItemsInSectionZero = 
                [self.cardCollectionView numberOfItemsInSection:SECTION_ZERO];
  NSUInteger  numItemsInSectionOne;

  NSMutableArray  *ipInsertionArraySectionZero = [[NSMutableArray alloc] init];
  NSMutableArray  *ipDeletionArraySectionZero = [[NSMutableArray alloc] init];
  NSMutableArray  *ipDeletionArraySectionOne;

        
  // Compute insertions or deletions to Section #0, as appropriate.
  // Compute deletions from Section #1, as appropriate.
  //
  if (numItemsInSectionZero < INITIAL_CARD_COUNT) {
    for (NSUInteger i = numItemsInSectionZero; i < INITIAL_CARD_COUNT; i++) {
      [ipInsertionArraySectionZero addObject: 
        [NSIndexPath indexPathForRow:i inSection:SECTION_ZERO]];
    }

  } else if (numItemsInSectionZero > INITIAL_CARD_COUNT) {
    for (NSUInteger i = INITIAL_CARD_COUNT; i < numItemsInSectionZero; i++) {
      [ipDeletionArraySectionZero addObject:
        [NSIndexPath indexPathForRow:i inSection:SECTION_ZERO]];
    }
  } 
  

  if (self.gNumberOfSections > 1) {
    numItemsInSectionOne      = [self.cardCollectionView numberOfItemsInSection:SECTION_ONE];
    ipDeletionArraySectionOne  = [[NSMutableArray alloc] init];

    for (NSUInteger i = 0; i < numItemsInSectionOne; i++) {
      [ipDeletionArraySectionOne addObject:
        [NSIndexPath indexPathForRow:i inSection:SECTION_ONE]];
    }

  }


  // Batch all updates to avoid intermediate inconsistencies of cell
  // or section count: 
  //   . Delete cells in Section #1, if they exist.
  //   . Delete Section #1, if it exists.
  //   . Insert or delete cells from Section #0, as necessary
  // 
  // TBD  Animating this section creates problems if the view includes
  //      cells from Section #1 because, having reset the game, the 
  //      discardPile is lost.
  //
  if (([ipInsertionArraySectionZero count] > 0) 
       || ([ipDeletionArraySectionZero count] > 0)
         || (self.gNumberOfSections > 1))
  {
    [self.cardCollectionView performBatchUpdates: ^{

        if (self.gNumberOfSections > 1) {
          if ([ipDeletionArraySectionOne count] > 0) {
            [self.cardCollectionView deleteItemsAtIndexPaths:ipDeletionArraySectionOne];
          }

          [self.cardCollectionView deleteSections:[NSIndexSet indexSetWithIndex:SECTION_ONE]];
          self.gNumberOfSections = 1;
        }

        if ([ipInsertionArraySectionZero count] > 0) {
          [self.cardCollectionView insertItemsAtIndexPaths:ipInsertionArraySectionZero];
        } else if ([ipDeletionArraySectionZero count] > 0) {
          [self.cardCollectionView deleteItemsAtIndexPaths:ipDeletionArraySectionZero];
        }
                                                    } // endblock
                                      completion: nil 
    ];
  }

} // rebuildCollection



//------------------- -o-
// updateCell:usingCard:
//
- (void) updateCell: (UICollectionViewCell *)cell 
          usingCard: (Card *)card
{
  if (! [cell isKindOfClass:[GameCollectionViewCell class]])  { return; }
  if (! [card isKindOfClass:[SetCard_v2 class]])              { return; }

  SetCardView  *setCardView  = ((GameCollectionViewCell *) cell).setCardView;
  SetCard_v2   *setCard      = (SetCard_v2 *)card;


#ifdef debugNOT
  NSIndexPath  *cardIndex = [self.cardCollectionView indexPathForCell:cell];
      // NB  cardIndex is nil in the absence of a selection.

[Dump objs:@[ 
    @"  ENTRY", setCard, @"at", 
    [NSString stringWithFormat:@"%@", (cardIndex) ? @(cardIndex.item) : @"NIL"],
    [NSString stringWithFormat:@":: SCV F%@   SC F%@ U%@ H%@", 
      (setCardView.isFaceUp) ? @"U" : @"d", 
      (setCard.isFaceUp)   ? @"U" : @"d", (setCard.isUnplayable) ? @"X" : @"_"],
      (setCard.isHinted)
]];
#endif


  setCardView.count = setCard.count;
  setCardView.shape = setCard.shape;
  setCardView.color = setCard.color;
  setCardView.shade = setCard.shade;

  setCardView.faceUp = setCard.isFaceUp;
  setCardView.hinted = setCard.isHinted;

} // updateCell:usingCard:



//------------------- -o-
// updateCell:usingDiscardGroup:
//
// TBD  Fix fussy naming: "Grouping" vs. "Group".
//
- (void)   updateCell: (UICollectionViewCell *)cell  
    usingDiscardGroup: (NSArray *)group
{
  if (! [cell isKindOfClass:[GameCollectionViewCell class]])  { return; }

  DiscardGroupingView  *discardGroupView  = 
    ((GameCollectionViewCell *) cell).setCardDiscardGroupingView;

  discardGroupView.group = group;

} // updateCell:usingDiscardGroup:



//------------------- -o-
// updateUI
//
// Card semantics--
//   unplayable  :: disabled, invisible (alpha=0) or removed
//   faceUp      :: highlighted background
//
// NB  Do not delete cells while traversing cells!  
//     First gather data then schedule deletions.
//
- (void) updateUI
{
  // Arrays of view cells and cards, collected for deletion later.
  //
  NSMutableArray  *ipSectionZeroDeletionArray  = [[NSMutableArray alloc] init];
  NSMutableArray  *ipSectionOneAdditionArray = [[NSMutableArray alloc] init];

  NSMutableArray  *cardList = [[NSMutableArray alloc] init];


  // First update to visible cells: necessary for incremental updates.
  //
  for (UICollectionViewCell *cell in [self.cardCollectionView visibleCells]) 
  {
    NSIndexPath *indexPath  = [self.cardCollectionView indexPathForCell:cell];

    if (SECTION_ZERO == indexPath.section) {
      Card  *card = [self.game cardAtIndex:indexPath.item];
      [self updateCell:cell usingCard:card];

    } else {                              // ASSUME SECTION_ONE
      NSArray  *group = [self.game discardGroupAtIndex:indexPath.item];
      [self updateCell:cell usingDiscardGroup:group];
    }
  } 



  // Review all cards in deck (beyond what is visible), note unplayable cards.
  // Create lists of cards to delete from active deck, and cells
  //   to delete from UICollectionView.
  //
  // NB  cardList and ipSectionZeroDeletionArray are constructed in parallel.
  //    
  for (int i = 0; i < [self.game.cards count]; i++)
  {
    Card  *card = [self.game cardAtIndex:i];

    if (card.isUnplayable) {
      [cardList addObject:card];
      [ipSectionZeroDeletionArray addObject:
        [NSIndexPath indexPathForRow:i inSection:SECTION_ZERO]];
    }
  }


  // Clear hinted flags before cards are removed from model.
  // Remove cards from the model of the active deck, erasing
  //   colored borders.
  // Add cards to discard pile.
  // Generate appropate indexPath to add to Section #1.
  //
  if ([cardList count] > 0) 
  {
    [(CardMatchingGameThree *)self.game clearHintedFlags];

    // Second update to visible cells: needed to handle selections.
    // NB  Must occur before animation, or updateCell:usingCard: changes order
    //     of cards in the view.  (?!)
    //
    for (UICollectionViewCell *cell in [self.cardCollectionView visibleCells]) 
    {
      NSIndexPath *indexPath  = [self.cardCollectionView indexPathForCell:cell];

      if (SECTION_ZERO == indexPath.section) {
        Card  *card = [self.game cardAtIndex:indexPath.item];
        [self updateCell:cell usingCard:card];

      } else {                            // ASSUME SECTION_ONE
        NSArray  *group = [self.game discardGroupAtIndex:indexPath.item];
        [self updateCell:cell usingDiscardGroup:group];
      }
    } 

    //
    for (Card *card in cardList) {
      [self.game.cards removeObject:card];
      ((SetCard_v2 *)card).faceUp = NO;
    }

    [self.game addCardsToDiscardPile:cardList];

    //
    NSUInteger  numItemsInSectionOne = 0;

    if (self.gNumberOfSections > 1) {
      numItemsInSectionOne = 
        [self.cardCollectionView numberOfItemsInSection:SECTION_ONE];
    }

    [ipSectionOneAdditionArray addObject:
      [NSIndexPath indexPathForRow:numItemsInSectionOne inSection:SECTION_ONE]];
  }


  //
  // Execute all UICollectionView changes in a single block
  // to avoid inconsistencies of cells or sections.  
  // Animation must encapsulate the entire block.
  //
  if (([ipSectionZeroDeletionArray count] > 0)
        || ([ipSectionOneAdditionArray count] > 0)) 
  {
    //
    // Allow border of final card to be highlighted.
    //
    [UIView transitionWithView: self.cardCollectionView
                      duration: 0
                       options: UIViewAnimationOptionTransitionNone    
                    animations: ^{ /*EMPTY*/ }
                    completion: ^(BOOL finished) {
                      if (!finished)  { return; }
                      //
                      // Pause for 1/2 second.
                      //
                      [UIView transitionWithView: self.cardCollectionView
                                        duration: 0.5
                                         options: UIViewAnimationOptionTransitionCrossDissolve   
                                      animations: ^{ /*EMPTY*/ }
                                      completion: ^(BOOL finished) {
                                        if (!finished)  { return; }
                                        //
                                        // Delete matching set from Section #0.
                                        // Add match group to Section #1.
                                        //
                                        [self.cardCollectionView performBatchUpdates: ^{

                                            if ([ipSectionZeroDeletionArray count] > 0) {
                                              [self.cardCollectionView deleteItemsAtIndexPaths:ipSectionZeroDeletionArray];
                                                                                    // delete cells from SECTION_ZERO
                                            }

                                            if ([ipSectionOneAdditionArray count] > 0) {
                                              if (1 == self.gNumberOfSections) {    // add SECTION_ONE 
                                                [self.cardCollectionView insertSections:[NSIndexSet indexSetWithIndex:SECTION_ONE]];
                                                self.gNumberOfSections = 2;
                                              }
                                              [self.cardCollectionView insertItemsAtIndexPaths:ipSectionOneAdditionArray];
                                                                                    // insert cells in SECTION_ONE
                                            }
                                                                                       } // endblock
                                                                          completion: nil ];
                                      } // endcompletion
                      ];
                    } // endcompletion
    ];
  } // endif



  // Post score to view.
  // Update SETGAME_SCORE_CURRENT.
  //
  self.scoreLabel.text 
            = [NSString stringWithFormat:@"Score: %d", self.game.score];

  ScoreTuple *st = 
    [[ScoreTuple alloc] initWithScore: self.game.score
                           flipsCount: self.flipsCount
                                 date: [NSDate date]
                          gameVersion: GSVersionTwo
                        matchGameType: nil];

  [Zed   udObjectSet: SETGAME_SCORE_CURRENT
       dictionaryKey: DICTIONARY_ROOT
              object: [st propertyListValue] ];


  
  // Handle descriptionLabelView of last move or history of moves in view.
  //   . At beginning: post game type
  //   . Update slider size
  //   . And post last move, unless instructed to...
  //   . Post previous history item
  //
  // NB  Set game posts UserMessage to UserMessageView via descriptionLabelView.
  //
  if ([self.game.actionHistory count] <= 0) {
      self.descriptionLabelView.messageData = 
        [[UserMessage alloc] initWithMessage:@"☁ SET MATCH ☁"];

      self.descriptionLabelView.alpha = ALPHA_OFF;

  } else {
    if (HISTORY_AT_CURRENT == self.historyIndex) {
      self.historySlider.maximumValue = [self.game.actionHistory count];
      self.historySlider.value = self.historySlider.maximumValue;

      self.descriptionLabelView.messageData  = self.game.action;
      self.descriptionLabelView.alpha        = ALPHA_OFF;

    } else {
      self.descriptionLabelView.messageData  = self.game.actionHistory[self.historyIndex];
      self.descriptionLabelView.alpha        = ALPHA_GREY;
    }
  }


  // State of "deal additional cards" button (+3) indicates 
  // whether or not the deck is empty.
  // 
  if ([self.game deckSize] <= 0)
  {
    self.dealAdditionalCardsButtonOutlet.alpha    = ALPHA_DISABLED;
    self.dealAdditionalCardsButtonOutlet.enabled  = NO;
  } else {
    self.dealAdditionalCardsButtonOutlet.alpha    = ALPHA_OFF;
    self.dealAdditionalCardsButtonOutlet.enabled  = YES;
  }



  // Verbose output of entire deck.
  //
#ifdef debug
  NSString *deckstr = @"DECKSTATUS... ";  

  for (int i = 0; i < [self.game.cards count]; i++) 
  {
    Card *card = [self.game cardAtIndex:i];
    deckstr = [NSString stringWithFormat:@"%@ %@%@",                    
        deckstr, card.contents, (card.isUnplayable ? @"X" : @"_") ];
  }

  [Dump o:deckstr]; 
#endif

} // updateUI

@end // @implementation SetGameViewController_v2

