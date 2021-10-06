
# WordSearchTranslate: Architecture and Orientation

Coded for iOS 12 with Swift 5 in Xcode 10.2.1.  Circa 2019.

Tested on iPhoneX, iPhone XS Max and iPad Pro in Simulator, and on a real iPhone7 device.

See file headers, type headers and comments for additional explanation.

Disable network access to play the alternate example puzzles, which are bundled with the app.



## Overview

This is a fun exercise I engaged after reading the Swift 5 language specification.

It is a word search game.  User is given words in one langauge and expected to find the equivalent word in a different language.
A session consists of a series of word search puzzles, all of which must be completed correctly to win.

Puzzles are defined by a simple, scalable JSON schema which may be custom designed for any size, dimentions, words or languages.

Designed so a single code path can run across all Apple device hardware formats.



## Model  

In WordSearchTranslate/ -- 
  
  * WordSearchPuzzleGroup.swift   :: Load or download puzzle files and manage puzzles during user play.
  * WordSearchPuzzle.swift        :: Parse and validate a given puzzle; check for valid word selections.
  * Settings.swift                :: Manage parameters that affect MODEL behavior.



## Views/Controllers  

In WordSearchTranslate/ -- 

  * PuzzleMasterVC.swift          :: Display instructions for current puzzle; provide interface to play and modify play lifecycle.
  * PuzzleDetailVC.swift          :: Display puzzle; manage and finesse gestures for word selection; protect play area from interruption by other views.
  * UIPuzzleElement.swift         :: Display a single puzzle element and manage its state.

  * PuzzleSettingsVC.swift        :: Interface to allow user to change VIEW behavior per Settings parameters.

  * UIPuzzleConstants.swift       :: UI globals constants.

  * AppDelegate.swift             :: App architecture and lifecycle; handle case of total data input failure.



## Support  

In mos/ -- 

  * types/Log.swift               :: Log levels; program context; exception management.
  * extensions/                   :: Shortcut methods to encapsulate, clarify or accessorize actions across all classes. 



## Tests

In WordSearchTranslateTests/ -- 

  * UnitTestsForModel.swift       :: Demonstration of Unit Tests against the MODEL.

q