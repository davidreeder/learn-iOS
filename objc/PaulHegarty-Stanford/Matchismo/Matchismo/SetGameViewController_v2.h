//
//  SetGameViewController_v2.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <UIKit/UIKit.h>

#import "SetCardDeck_v2.h"
#import "SetCard.h"
#import "SetCardView.h"

#import "CardMatchingGameThree.h"

#import "GameViewController_v2.h"
#import "GameCollectionViewCell.h"

#import "GameSettingsViewController.h"
#import "ScoreTuple.h"

#import "SectionTitleView.h"




//---------------------------------------------------- -o-
#undef debug  
//#define debug                 

@interface SetGameViewController_v2 : GameViewController_v2

  // "+3" button to deal (three) additional Set Game cards
  //
  @property (weak, nonatomic) IBOutlet UIButton *dealAdditionalCardsButtonOutlet;

  - (IBAction)dealAdditionalCardsButtonAction:(UIButton *)sender;


  // "Hint" button to highlight a random existing match.
  //
  @property (weak, nonatomic) IBOutlet UIButton *hintButtonOutlet;

  - (IBAction)hintButtonAction:(UIButton *)sender;


  //
  - (void) updateUI;


  //---------------------------------------------------- -o--
  // UICollectionViewDataSource and UICollectionViewDelegateFlowLayout protocol.
  //
  - (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *)collectionView;

  - (NSInteger) collectionView: (UICollectionView *) collectionView
	numberOfItemsInSection: (NSInteger)          section;

  - (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
		     cellForItemAtIndexPath: (NSIndexPath *)      indexPath;

  - (UICollectionReusableView *) collectionView: (UICollectionView *)collectionView
	      viewForSupplementaryElementOfKind: (NSString *)kind
				    atIndexPath: (NSIndexPath *)indexPath ;

  - (CGSize) collectionView: (UICollectionView *)      collectionView 
		     layout: (UICollectionViewLayout*) collectionViewLayout 
     sizeForItemAtIndexPath: (NSIndexPath *)           indexPath;

@end

