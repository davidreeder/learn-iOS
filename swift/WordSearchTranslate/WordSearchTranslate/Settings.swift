//
// Settings.swift
//
//
//---------------------------------------------------------------------
//     Copyright (C) 2019 David Reeder.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

import  Foundation
import  UIKit




//------------------------------------------------- -o--
// MARK: -

/**
 * Configuration options for WordSearchTranslate app.
 */

class  Settings
{
    //------------------------------------------------------------ -o-
    // MARK: Type definitions.

    enum  DisplayTranslation  :Int  {
        case  no = 0
        case  yes
    }

    static let  displayTranslationRange  = DisplayTranslation.no.rawValue...DisplayTranslation.yes.rawValue



    //------------------------------------------------- -o--
    // MARK: Constants.

    // URLs.
    //
    static let  kPuzzleURLRemoteDataSet   = "https://somewhere-dot-tld/remote-dataset.txt"   #XXX


    // Local files.
    //
    static let  kPuzzleFileAlternateExamples  = "puzzleGroup--alternateExamples.txt"
    static let  kPuzzleFileMain               = "puzzleGroup--main.txt"

    static let  kPuzzleFileTesting1  = "puzzleGroup--Testing1--brokenExamples.txt"
    static let  kPuzzleFileTesting2  = "puzzleGroup--Testing2--emptyFile.txt"



    //------------------------------------------------- -o--
    // MARK: - Properties.

    /// URL from which to read the WordSearchPuzzleGroup.
    var  puzzleURLString  = kPuzzleURLRemoteDataSet

    /// Local file to read if URL resource should fail.
    var  puzzleFile  = kPuzzleFileAlternateExamples


    /// Iterate through `WordSearchPuzzle`s in order or randomly.
    var  puzzleIterationMethod  = WordSearchPuzzleGroup.IterationMethod.random      //DEFAULT

    /// Display the words to find or, alternately, just how many words to find.
    var  displayTranslation  = DisplayTranslation.no                                //DEFAULT


    /**
     *  Pointer to the UISplitViewController that governs the view architecture.
     *  Provides a means for SettingsVC to reach out to the other view controllers.
     */
    var  splitVC  :UISplitViewController?



    //------------------------------------------------- -o--
    // MARK: - Singleton.

    static private var  sharedSettings  :Settings  = { return Settings() }()

    static var  shared  :Settings  { return sharedSettings }
}
