
## README :: Matchismo ##
- - - -

David Reeder
http://mobilesound.org


This Xcode project represents a solution to the Matchismo assignments given by Paul Hegarty to his students at Stanford during his Winter 2012-2013 course titled "Developing Apps for iOS" (CS193P) which covers the fundamentals of development with iOS 6.  Autolayout updated for iOS7.

For more information about these courses, and how to download the lectures and materials via iTunesU, please see:

> http://www.stanford.edu/class/cs193p


Barring a few trivial exceptions, this version of Matchismo solves every Requirement and includes all Extra Credit given in assignments #1 through #3.  Since Matchismo underwent significant revision between assignments #2 and #3, the UITabViewController has been extended to allow selection of the first versions (v1) of the Match and Set games.  Files and objects for the second version of the Match and Set games are sometimes suffixed with "_v2".

This solution to Matchismo demonstrates the following use of Objective-C and the iOS Framework:

* implementation of Match and Set games, versions 1 and 2

* MVC design patterns

* subclassing in both the view and the model

* storyboard, target-actions and outlets

* protocols for Delegation design pattern

* common containers such as NSString, NSAttributedString, NSArray and NSDictionary

* Property Lists and management of user defaults

* demonstration of UICollectionViews including: multiple, dynamically allocated sections; heterogeneous, dynamic UICollectionViewCells; supplementary Headers and Footers.

* UITabViewController including custom control over UITabBarController defaults.

* customized UIViews to handle image and text

* Pinch and Tap gestures

* custom drawings with UIBezierPath (ie: programmer art!)

* animations for view sequences that highlight cells before updating the UICollectionView

* use of Autolayout -- Portrait and Landscape, 3.5" and 4" iPhones (version 2 games only) 

* clear feedback to the user at all times during the game

* two and three card match games; game history

* a simple UIWebView to document Set via Wikipedia

* Settings tab to configure the games and score display, including choosing which game appears first at boot

* test for the existence of Set matches as a means to improve scoring, display of hints and to determine proper game play

* small library of utility classes for debugging, logging, management of user defaults, CGPoint calculations and other miscellaneous


NOTE -- The rules for Autolayout changed between iOS6 and iOS7.  All touch logic from iOS6 version is now available.  However, the results are fussy! 

Shifting between portrait and landscape will correct UI for missing or improperly sized UI objects.
If touch is not responding in landscape, fix this by shifting between Set and Match Games while keeping landscape orientation.






## README :: Spot ##
- - - -

David Reeder
http://mobilesound.org 

Spot browses image collections at Flickr.  For iPhone and iPad.

This Xcode project represents a solution to the second Spot assignment given by Paul Hegarty to his students at Stanford during his Winter 2012-2013 course titled "Developing Apps for iOS" (CS193P) which covers the fundamentals of iOS development.  This project is implemented in iOS 7.

In addition, this project also demonstrates Test Driven Design (TDD) using the Specta framework.  Image caching is implemented via a stand-alone class called DataFileCache.  Prior to integration with Spot, DataFileCache was independently designed and tested using Specta tools.  The test specification may be found in danaprajna/classes/specta/DataFileCacheSpec_A.m .



For more information about the Stanford courses taught by Paul Hegarty, please see:

> http://www.stanford.edu/class/cs193p



This version of Spot solves every Requirement and includes all Extra Credit given in assignments #4 and #5:

* View controllers: UITableViewContrller, UINavigationViewController, UISplitViewController, UIScrollView

* Segues between view controllers

* Grand Central Dispatch (GCD) to serialize operations and to decouple multiple UI dependent upon asynchronous network data

* Resource management and data storage techniques: NSURL, NSFileManager, NSUserDefaults, Property Lists, NSData

* Fetching and managing data from network APIs (eg, Flickr)

* Maintaining freshness of data presentation despite arbitrary, asynchronous inputs

* Building shared UI for both iPhone and iPad

* Use of blocks, notably with Objective-C containers and GCD 

* Sorting, searching, selection from large data sets using Objective-C container features

* UI features to provide feedback on network usage and error states



This Xcode project also includes:

* Test Driven Design (TDD) using the Specta framework

* Use of CocoaPods for Xcode package management

* A library of tools for Debugging, Logging and other common functions (see danaprajna/util)

* A general class, TestSandbox, to manage ephemeral directories and to create arbitrary test file data (see danaprajna/classes/specta)


