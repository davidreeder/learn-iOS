
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

