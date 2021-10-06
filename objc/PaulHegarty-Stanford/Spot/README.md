
## Spot ##


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


