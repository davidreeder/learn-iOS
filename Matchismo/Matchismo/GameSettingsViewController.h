//
//  GameSettingsViewController.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <UIKit/UIKit.h>

#import "MatchingGame.h"

#import "Danaprajna.h"



//---------------------------------------------------- -o-
#undef debug
//#define debug          

@interface GameSettingsViewController : UIViewController

  // EMPTY.  

@end



//---------------------------------------------------- -o-
//
// NSUserDefaults dictionary root
//
#define DICTIONARY_ROOT                 @"Matchismo"


//
// Object keys under dictionary root
//
// /SCORE_SORT_ELEMENT|START_GAME_TYPE|MATCHGAME_TYPE|MATCHGAME_SCORES|MATCHGAME_SCORE_CURRENT|SETGAME_SCORES|SETGAME_SCORE_CURRENT
//
#define START_GAME_TYPE                 @"START_GAME_TYPE"      
    // first visible game on startup

#define MATCHGAME_TYPE                  @"MATCHGAME_TYPE"      
    // first visible game in Match category
#define MATCHGAME_NUMCARDS              @"MATCHGAME_NUMCARDS"
    // number of cards to be dealt in Match game 

#define SCORE_SORT_ELEMENT              @"SCORE_SORT_ELEMENT"   
    // which element of score tuple upon which to sort

#define MATCHGAME_SCORES               @"MATCHGAME_SCORES"
#define MATCHGAME_SCORE_CURRENT        @"MATCHGAME_SCORE_CURRENT"
#define SETGAME_SCORES                 @"SETGAME_SCORES"
#define SETGAME_SCORE_CURRENT          @"SETGAME_SCORE_CURRENT"
    // arrays of previous scores and current score for Match and Set




//---------------------------------------------------- -o-
// Dictionary keys for NSUserDefaults
//
// NB  Enums must match UI segment switches!
//

typedef enum { GSSortByScore = 0, GSSortByFlips, GSSortByDate } 
                                                          GSScoreSortElement;
typedef enum { GSMatchGame = 0, GSSetGame }               GSStartGame;
typedef enum { GSVersionOne = 1, GSVersionTwo }           GSGameVersion;
typedef enum { GSTwoCardMatch = 0, GSThreeCardMatch }     GSMatchGameType;

