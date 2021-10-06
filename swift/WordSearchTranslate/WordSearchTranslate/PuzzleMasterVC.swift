//
// PuzzleMasterVC.swift
//
//
//---------------------------------------------------------------------
//     Copyright (C) 2019 David Reeder.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

import UIKit



//------------------------------------------------------------ -o--
// MARK: -

/**
 *  Display instructions for each WordSearchPuzzle.
 *  `segueButtonAction(sender:)` presents user options and
 *    serves as one of two primary pivots for game lifecycle.
 */

class  PuzzleMasterVC  : UIViewController, UISplitViewControllerDelegate, UIPopoverPresentationControllerDelegate
{
    //------------------------------------------------------------ -o-
    // MARK: Constants.

    let  kSearchInstructions  =
    """
            Search the puzzle for one or more translations from __SOURCELANGUAGE__ into __TARGETLANGUAGE__.

            Translate this word: '__SOURCEWORD__'.
            """

    let  kSourceLanguagePlaceholder  = "__SOURCELANGUAGE__"
    let  kTargetLanguagePlaceholder  = "__TARGETLANGUAGE__"

    let  kSourceWordPlaceholder      = "__SOURCEWORD__"


    //
    let  kPuzzleGoalFeedbackWordCount =
    """
            Number of remaining translations:
            __NNN__
            """

    let  kPuzzleGoalFeedbackWordList =
    """
            Translated words to find:
            __TARGETWORDLIST__
            """

    let  kPuzzleGoalWordCountPlaceholder        = "__NNN__"
    let  kPuzzleGoalTargetWordListPlaceholder   = "__TARGETWORDLIST__"

    let  kNewlineSpacer  = "\n\n\n"


    //
    let  kDelayBeforeDisplayingAlertUponFirstAppearance  = 0.100



    //------------------------------------------------------------ -o-
    // MARK: - IB relationships.

    @IBOutlet weak var  puzzleInstructionsTextView: UITextView!



    //------------------------------------------------------------ -o-
    // MARK: - Properties.

    var  wordSearchPuzzleGroup  :WordSearchPuzzleGroup?
    var  wordSearchPuzzle       :WordSearchPuzzle?

    var  loadedAlternateWordSearchPuzzleGroup  = false

    lazy var  settings  = Settings.shared


    //
    lazy var  splitVC   = splitViewController!

    lazy var  masterVC  = splitVC.masterAsNavigationController.topViewController as! PuzzleMasterVC

    /**
     * Encapsulate the means of acquiring pointer to `PuzzleDetailVC`.
     * Use private, backing property to cache `PuzzleDetailVC` to ensure
     *   the same DetailVC object is used for each segue.
     * Setter allows input in corner cases, such as from prepare(for segue:).
     */
    var  detailVC  :PuzzleDetailVC
    {
        set  { detailVC_ = newValue }

        get  {
            if  detailVC_ == nil
            {
                if  splitVC.detailIsNavigationController  {
                    detailVC_ = splitVC.detailAsNavigationController.viewControllers.last as? PuzzleDetailVC
                } else {
                    detailVC_ = splitVC.viewControllers.last as? PuzzleDetailVC
                }

                if  detailVC_ == nil  {
                    Log.fatal("COULD NOT ACQUIRE PuzzleDetailVC.")
                }
            }

            return  detailVC_!
        }
    }

    private var  detailVC_  :PuzzleDetailVC?


    // Values for UINavigationItem.rightBarButtonItem, presented per game state.
    //
    lazy var  segueButtonSearchPuzzle      = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.search,
                                                                    target:self, action:#selector(segueButtonAction))
    lazy var  segueButtonReplayAllPuzzles  = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.refresh,
                                                                    target:self, action:#selector(segueButtonAction))
    lazy var  segueButtonNextPuzzle        = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.fastForward,
                                                                    target:self, action:#selector(segueButtonAction))

    /// Gear icon image taken from https://icons8.com/icon/set/gear/ios .
    lazy var  settingsButton  = UIBarButtonItem(image:UIImage(named:"gearIcon"), style:.plain, target:self, action:#selector(settingsButtonAction))


    //
    var  settingsPopoverPresentationController  :UIPopoverPresentationController?

    var  puzzleInstructionsFontSize  = UIPuzzleConstants.undefinedCGFloat



    //------------------------------------------------------------ -o-
    // MARK: - Lifecycle.

    override func  viewDidLoad()
    {
        super.viewDidLoad()


        // Do nothing if app is run via UnitTestsForModel.
        //
        if  ProcessInfo.contains(argument:"XCTEST_IS_ACTIVE")  { return }


        //
        view.backgroundColor = UIPuzzleConstants.dlColorLightPurple
        puzzleInstructionsTextView.showsVerticalScrollIndicator = true

        splitVC.delegate = self
        settings.splitVC = splitVC   // Allow SettingsVC access to the other view controllers.

        masterVC.navigationItem.leftBarButtonItem = settingsButton


        //
        wordSearchPuzzleGroup = try? WordSearchPuzzleGroup(withURLString:settings.puzzleURLString, iterationMethod:settings.puzzleIterationMethod)

        if  wordSearchPuzzleGroup == nil
        {
            try!  Log.error("FAILED TO DOWNLOAD WordSearchPuzzleGroup.  (\(settings.puzzleURLString))")
            Log.info("Try loading local file...  (\(settings.puzzleFile))")

            wordSearchPuzzleGroup = try? WordSearchPuzzleGroup(withFile:settings.puzzleFile, iterationMethod:settings.puzzleIterationMethod)
            loadedAlternateWordSearchPuzzleGroup = true
        }
    }


    override func  viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        guard let  wspg = wordSearchPuzzleGroup  else {
            try!  Log.error("wordSearchPuzzleGroup IS UNDEFINED.")
            return
        }


        // If DetailVC is NOT a UINavigationController, then set DetailVC properties here.
        // Otherwise, the the update is triggered by the UINavigationItem.rightBarButtonItem.
        //
        if  !splitVC.detailIsNavigationController
        {
            detailVC.intakeWordSearchPuzzle(wspg.currentPuzzle!, isLastPuzzle:wspg.isLastPuzzle)
        }


        //
        updateView()
    }


    override func  viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        // Instructions may span greater than the horizontal distance of PuzzleMasterVC.view.
        // Eg: When user's Dynamic Type setting is large.
        //
        puzzleInstructionsTextView.scrollRangeToVisible(NSMakeRange(0,0))
        puzzleInstructionsTextView.flashScrollIndicators()
    }


    func  updateView()
    {
        guard let  wspg  = wordSearchPuzzleGroup,
              let  wsp   = wspg.currentPuzzle
        else {
            try!  Log.error("wordSearchPuzzleGroup or wordSearchPuzzle IS UNDEFINED.")
            return
        }


        // Update UINavigationItem.rightBarButtonItem to reflect state of game play.
        //
        // NB  This method updates the display for the next step of game lifecycle.
        //     Game lifecycle is advanced when UINavigationItem.rightBarButtonItem is clicked.
        //     See also segueButtonAction().
        //
        if  wspg.numberOfUnsolvedPuzzles <= 0  {
            masterVC.navigationItem.rightBarButtonItem = segueButtonReplayAllPuzzles

        } else if  wsp.isPuzzleSolved  {
            masterVC.navigationItem.rightBarButtonItem = segueButtonNextPuzzle

        } else {
            if  splitVC.detailIsNavigationController  {
                masterVC.navigationItem.rightBarButtonItem = segueButtonSearchPuzzle
            } else {
                masterVC.navigationItem.rightBarButtonItem = nil
            }
        }


        // Update puzzle instructions.
        //   Use a font that supports Dynamic Type.
        //
        let  instructionText  = kSearchInstructions
                .replacingOccurrences(of: kSourceLanguagePlaceholder,       with: Locale.languageNameForIdentifier(languageIdentifier:wsp.sourceLanguage))
                .replacingOccurrences(of: kTargetLanguagePlaceholder,       with: Locale.languageNameForIdentifier(languageIdentifier:wsp.targetLanguage))
                .replacingOccurrences(of: kSourceWordPlaceholder,           with: wsp.sourceWord)


        var  puzzleGoalFeedback  = ""

        if  settings.displayTranslation == .yes
        {
            puzzleGoalFeedback  = kPuzzleGoalFeedbackWordList
                .replacingOccurrences(of: kPuzzleGoalTargetWordListPlaceholder,  with: wsp.unmatchedWords.joined(separator:"\n"))
        } else {
            puzzleGoalFeedback  = kPuzzleGoalFeedbackWordCount
                .replacingOccurrences(of: kPuzzleGoalWordCountPlaceholder,       with: String(wsp.numberOfUnmatchedWords))
        }


        puzzleInstructionsTextView.text = instructionText + kNewlineSpacer + puzzleGoalFeedback + "\n"

        
        //
        if  UIDevice.isIPad  {
            puzzleInstructionsFontSize = 24
        } else {
            puzzleInstructionsFontSize = 17
        }

        let  puzzleInstructionsFont          = UIFont.systemFont(ofSize:puzzleInstructionsFontSize)
        let  puzzleInstructionsFontScalable  = UIFontMetrics(forTextStyle:.body).scaledFont(for:puzzleInstructionsFont)

        puzzleInstructionsTextView.font = puzzleInstructionsFontScalable
        puzzleInstructionsTextView.adjustsFontForContentSizeCategory = true


        // Inform user when network error failed to download current WordSearchPuzzleGroup.
        // Delay this a smidge to be sure it appears as top view, after all other views are presented.
        //
        if  loadedAlternateWordSearchPuzzleGroup
        {
            loadedAlternateWordSearchPuzzleGroup = false   // Present the alert only once per app lifecycle!

            DispatchQueue(label:Log.context(), qos:.background).async
            {
                Thread.sleep(forTimeInterval:self.kDelayBeforeDisplayingAlertUponFirstAppearance)
                DispatchQueue.main.async {
                    let _ =  UIAlertController.postAlertOneButton(
                                                 title:    "Playing alternate Puzzle.",
                                                 message:  "Could not load current puzzle via the network.",
                                                 parent:   self )
                }
            }
        }
    }


    deinit  {
        detailVC_ = nil
    }



    //------------------------------------------------------------ -o-
    // MARK: - Navigation

    override func  prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch  segue.identifier
        {
        case  "segueToPuzzleDetail":
            guard let  segueDestination = segue.destination as? PuzzleDetailVC  else {
                Log.fatal("COULD NOT ACQUIRE PuzzleDetailVC.")
                return
            }

            detailVC = segueDestination

            detailVC.intakeWordSearchPuzzle( wordSearchPuzzleGroup!.currentPuzzle!,
                                             isLastPuzzle:wordSearchPuzzleGroup!.isLastPuzzle )
            return

        case  "segueToPuzzleSettings":
            guard let  segueDestination = segue.destination as? PuzzleSettingsVC  else {
                Log.fatal("COULD NOT ACQUIRE PuzzleSettingsVC.")
                return
            }

            settingsPopoverPresentationController = segueDestination.popoverPresentationController!

            settingsPopoverPresentationController?.barButtonItem = settingsButton
            settingsPopoverPresentationController?.delegate = self

            settingsPopoverPresentationController?.backgroundColor = UIPuzzleConstants.dlColorLightGreen

        default:
            Log.fatal("UNKNOWN segue.identifier.  (\(String(describing:segue.identifier)))")
        }
    }



    //------------------------------------------------------------ -o-
    // MARK: - IB Actions.

    @objc func  settingsButtonAction(sender: UIBarButtonItem)
    {
        performSegue(withIdentifier:"segueToPuzzleSettings", sender:sender)
    }


    /**
     *  Advance game lifecycle, via UINavigationItem.rightBarButtonItem.
     *  Serve as one of two primary pivots for WordsearchPuzzle game lifecycle.
     *  See also `PuzzleDetailVC.handlePanGesture(:)`.
     *
     *  The button icon allows the user to advance through the puzzles,
     *    and to refresh the game state after the last puzzle has been completed.
     *  See also updateView().
     *
     *  Of the three buttons states, only `segueButtonSearchPuzzle` invokes the DetailVC,
     *    either by segue or push.  This button is only present when the MasterVC
     *    and DetailVC cannot be simulataneously presented.
     *
     *  The other two buttons states manage game state and communicate with the user
     *    by updating the MasterVC:
     *    * `segueButtonNextPuzzle` finds the next WordSearchPuzzle.
     *    * `segueButtonReplayAllPuzzles` reloads the current set of puzzles.
     */
    @objc func  segueButtonAction(sender: UIBarButtonItem)
    {
        let  wspg  = wordSearchPuzzleGroup!


        // Present DetailVC.
        //
        if  sender == segueButtonSearchPuzzle
        {
            Log.info("SEGUE TO current puzzle search.")

            if  (detailVC_ == nil) || (wspg.currentPuzzle!.isPuzzleNew)
            {
                performSegue(withIdentifier:"segueToPuzzleDetail", sender:sender)

            } else {
                let  navigationController  = splitVC.masterAsNavigationController
                navigationController.pushViewController(detailVC, animated:true)
            }

            return
        }


        // Update both DetailVC and MasterVC.
        //
        if  sender == segueButtonNextPuzzle  {
            Log.info("FIND NEXT PUZZLE.")

        } else if  sender == segueButtonReplayAllPuzzles  {
            Log.info("RESET GAME.")
            wspg.restartIteration(iterationMethod:settings.puzzleIterationMethod)

        } else {
            Log.fatal("UNKNOWN sender.  (\(sender))")
        }

        detailVC.intakeWordSearchPuzzle(wspg.nextPuzzle!, isLastPuzzle:wspg.isLastPuzzle)
        updateView()
    }



    //------------------------------------------------------------ -o-
    // MARK: - UISplitViewControllerDelegate

    func splitViewController( _ splitViewController                         : UISplitViewController,
                              collapseSecondary secondaryViewController     : UIViewController,
                              onto primaryViewController                    : UIViewController
            ) -> Bool
    {
        // Check that puzzleWinAlert has been dismissed, otherwise it blocks touches on MasterVC.
        // In particular, on iPhoneXSMax in landscape, if alert is not dismissed before rotating to portrait.
        //
        if let  puzzleWinAlert = detailVC_?.puzzleWinAlert
        {
            puzzleWinAlert.dismiss(animated:false)
            detailVC_?.puzzleWinAlert = nil
        }


        /*
         * Handle cases where MasterVC does not naturally display after DetailVC has been updated.
         * In particular, on iPhoneXSMax when the app begins in portrait orientation, then...
         *   segues to DetailVC, then rotates to landscape, then updates puzzle, then rotates back to portrait
         *   ...before popping DetailVC to return to MasterVC -- which is then updated from here.
         */
        updateView()

        return  true
    }


    func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewController.DisplayMode
    {
        if  UIDevice.isIPad  {
            return  .allVisible
        }


        // Handle case where iPhoneXSMax switches from SplitVC as NavigationController (portrait)
        //   to SplitVC, per se (landscape), before naturally updating DetailVC.
        // This happens when app opens in portrait, then rotates to landscape.
        //
        // Thread.sleep() prevents a race condition where returning .primaryOverlay appears to have
        //   scheduling priority over completing the call to intakeWordSearchPuzzle().
        //   The 1/4 second sleep on main thread imperceptibly extends the natural delay of the
        //   rotation and subsequent layout update.
        //
        if     (wordSearchPuzzleGroup != nil)
            && (detailVC.wordSearchPuzzle == nil)
        {
            detailVC.intakeWordSearchPuzzle( wordSearchPuzzleGroup!.currentPuzzle!,
                                             isLastPuzzle:wordSearchPuzzleGroup!.isLastPuzzle )

            Thread.sleep(forTimeInterval:0.25)   //XXX
        }


        //
        return  .primaryOverlay
    }



    //------------------------------------------------------------ -o-
    // MARK: - UIPopoverPresentationControllerDelegate

    // Retains small popover in all cases, except iPhoneXSMax in landscape orientation.
    //
    func  adaptivePresentationStyle(for controller: UIPresentationController)  -> UIModalPresentationStyle
    {
        return  .none
    }

}

