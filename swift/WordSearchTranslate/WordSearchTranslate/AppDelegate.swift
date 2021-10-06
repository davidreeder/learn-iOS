//
// AppDelegate.swift
//
//
//---------------------------------------------------------------------
//     Copyright (C) 2019 David Reeder.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

import UIKit



//------------------------------------------------ -o--
// MARK: -

@UIApplicationMain
class  AppDelegate  : UIResponder, UIApplicationDelegate
{
    //------------------------------------------------ -o-
    // MARK: Properties.

    var  window  :UIWindow?

    /// UISplitViewController defined in Main.storyboard.
    lazy var  splitVC  = window!.rootViewController as! UISplitViewController



    //------------------------------------------------ -o-
    // MARK: - UIApplicationDelegate.

    func application( _ application                                 : UIApplication,
                      didFinishLaunchingWithOptions launchOptions   : [UIApplication.LaunchOptionsKey : Any]?
            ) -> Bool
    {
        Log.minimumLogLevel = .info

        configureSplitVC()


        //
        return true
    }


    // Update user instructions when returning from the background.
    // Take this opportunity to fail gracefully if app starts with no data.
    //
    func  applicationDidBecomeActive(_ application: UIApplication)
    {
        // Do nothing if app is run via UnitTestsForModel.
        //
        if  ProcessInfo.contains(argument:"XCTEST_IS_ACTIVE")  { return }


        //
        let  masterVC  = splitVC.masterAsNavigationController.viewControllers.first as! PuzzleMasterVC

        configureSplitVC()


        // Quit if no WordSearchPuzzleGroup is available.
        //
        guard  masterVC.wordSearchPuzzleGroup != nil
        else {
            // Match background color of LaunchScreen.storyboard.
            splitVC.view.backgroundColor = UIPuzzleConstants.dlColorDarkGreen

            masterVC.view.isHidden = true
            splitVC.masterAsNavigationController.navigationBar.isHidden = true
            splitVC.viewControllers.last?.view.isHidden = true

            UIAlertController.postAlertFatalError("COULD NOT LOAD data!", parent:splitVC)

            return
        }


        // Update per changes to system Settings, including fonts scaled via Dynamic Type.
        //
        masterVC.updateView()
    }



    //------------------------------------------------ -o-
    // MARK: - Helper methods.

    func  configureSplitVC()
    {
        // Throughout the app...
        //   * SplitVC on iPad is always presented with both MasterVC and DetailsVC visible.
        //   * The other cases of Size Class Regular (eg: iPhone Max and Plus) are handled by presenting
        //       DetailVC first, with MasterVC presenting as an overlay, when appropriate.
        //
        if  UIDevice.isIPad  {
            splitVC.preferredDisplayMode = .allVisible
        } else {
            splitVC.preferredDisplayMode = .primaryOverlay
        }
    }

}

