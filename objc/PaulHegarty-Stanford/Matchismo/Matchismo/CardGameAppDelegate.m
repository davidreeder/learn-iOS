//
//  CardGameAppDelegate.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "CardGameAppDelegate.h"
#import "GameSettingsViewController.h"



//---------------------------------------------------- -o-
@implementation CardGameAppDelegate


//------------------- -o-
// Override point for customization after application launch.
//
- (BOOL)              application: (UIApplication *)application 
    didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
#ifdef debug
  DP_MARK(application:didFinishLaunchingWithOptions:);

  [Dump     dict: [Zed udGet:DICTIONARY_ROOT]
      withHeader: @"DEFAULTS"
  ];
#endif

  // DEBUG ONLY
  //[Zed udRemove:DICTIONARY_ROOT]; [Log debugMsg:@"** ERASED DICTIONARY! **"];


  // Bookkeeping for previously recorded "current" scores.
  //
  [GameViewController recordCurrentMatchGameScore];
  [GameViewController recordCurrentSetGameScore];


  // Select game from UITabViewController according to user defaults.
  //
  NSUInteger startGame = 
    [Zed udUIntegerGet: START_GAME_TYPE dictionaryKey: DICTIONARY_ROOT];

  if (GSSetGame == startGame) {
    UITabBarController *tbc = 
      (UITabBarController *) self.window.rootViewController;

    tbc.selectedIndex = 1;      
      // XXX  MAGIC NUMBER from Interface Builder values for UITabBarController
  }


  return YES;

} // application:didFinishLaunchingWithOptions:
                                                        


//------------------- -o-
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}



//------------------- -o-
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}



//------------------- -o-
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}



//------------------- -o-
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}



//------------------- -o-
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

