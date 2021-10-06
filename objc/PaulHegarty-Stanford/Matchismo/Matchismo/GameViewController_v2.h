//
// GameViewController_v2.h
//
// ABSTRACT CLASS.
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <UIKit/UIKit.h>

#import "GameSettingsViewController.h"
#import "PlayingCardDeck.h"
#import "CardMatchingGame.h"
#import "CardMatchingGameThree.h"
#import "GameSettingsViewController.h"
#import "ScoreTuple.h"
#import "UserMessageView.h"

#import "Danaprajna.h"



//---------------------------------------------------- -o-
// Allows TWO-card match game only.  
//   Makes THREE-card game inaccessible.
//
//#define TWOCARD_MATCHGAME_ONLY           

#define ALPHA_OFF       1.0
#define ALPHA_GREY      0.6
#define ALPHA_DISABLED  0.25

#define HISTORY_AT_CURRENT  -1



//---------------------------------------------------- -o-
@interface GameViewController_v2 
    : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

  @property (weak, nonatomic)    IBOutlet UILabel     *flipsLabel;
  @property (nonatomic)                   int          flipsCount;

  @property (weak, nonatomic)    IBOutlet UILabel     *scoreLabel;

  // descriptionLabel for Card Match game; descriptionLabelView for Set Match game.
  //
  @property (weak, nonatomic)    IBOutlet UILabel          *descriptionLabel;
  @property (weak, nonatomic)    IBOutlet UserMessageView  *descriptionLabelView;
      // NB  For Autolayout -- use fixed width and height to support formatting
      //     decisions in UserMessage.

  @property (weak, nonatomic)    IBOutlet UISlider    *historySlider;
  @property (nonatomic)                   int          historyIndex;


  // matchGameType distinguishes between 2- and 3-card Match game.
  //
#if !defined(TWOCARD_MATCHGAME_ONLY)
  @property (nonatomic)                   int          matchGameType;
#endif

  @property (strong, nonatomic)           CardMatchingGame  *game;      // ABSTRACT


  @property (weak, nonatomic)    IBOutlet UICollectionView  *cardCollectionView;


  + (void) recordCurrentMatchGameScore;
  + (void) recordCurrentSetGameScore;

  - (IBAction) flipCardWithGesture: (id)   sender;

  - (IBAction) dealAction:    (UIButton *) sender;
  - (IBAction) sliderAction:  (UISlider *) sender;

  - (void) updateCell: (UICollectionViewCell *) cell            // ABSTRACT
            usingCard: (Card *)                 card;

  - (void) updateUI;



  //---------------------------------------------------- -o-
  // Protocol UICollectionViewDataSource
  //

  - (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *)collectionView;

  - (NSInteger) collectionView: (UICollectionView *) collectionView
        numberOfItemsInSection: (NSInteger)          section;   // ABSTRACT

  - (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                     cellForItemAtIndexPath: (NSIndexPath *)      indexPath;

@end

