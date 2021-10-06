//
// PuzzleDetailVC.swift
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
 *  Display WordSearchPuzzle.
 *  Manage and finesse gestures for word selection.
 *  Protect play area from interruption by other views.
 *
 *  `handlePanGesture(:)` serves as one of two primary pivots for game lifecycle.
 */

class  PuzzleDetailVC  : UIViewController, UIGestureRecognizerDelegate
{
    //------------------------------------------------------------ -o-
    // MARK: Constants.

    let  kAlertOnePuzzleSolvedMessage  = "The puzzle is solved!"

    let  kAlertAllPuzzlesSolvedTitle    = "Congratulations"
    let  kAlertAllPuzzlesSolvedMessage  = "All the puzzles have been solved!"



    //------------------------------------------------------------ -o-
    // MARK: - Properties.

    //
    var  wordSearchPuzzle  :WordSearchPuzzle?
    var  isLastPuzzle      = false
    var  isPuzzleSolved    = false


    //
    var  splitVC  :UISplitViewController?


    //
    var  puzzleBox              = UIView()
    var  puzzleBoxSideLength    :CGFloat = UIPuzzleConstants.undefinedCGFloat
    var  puzzleBoxCenter        = CGPoint.zero

    lazy var  characterDisplayGrid   = [[UIPuzzleElement]]()   //PLACEHOLDER


    /// Gesture by which the user may capture puzzle elements to spell a target word.
    lazy var  panGesture  = UIPanGestureRecognizer(target:self, action:#selector(handlePanGesture))

    /// Gesture provided by UINavigationController to swipe-right and segue back to MasterVC from DetailVC.
    var  navconInteractivePopGesture  :UIGestureRecognizer?


    /// Alert popup for when the user completes a puzzle, including special case when all puzzles are completed.
    var  puzzleWinAlert  :UIAlertController?



    //------------------------------------------------------------ -o-
    // MARK: - Lifecycle.

    override func  viewDidLoad()
    {
        super.viewDidLoad()

        // Do nothing if app is run via UnitTestsForModel.
        //
        if  ProcessInfo.contains(argument:"XCTEST_IS_ACTIVE")  { return }


        //
        view.backgroundColor = UIColor.black

        splitVC = splitViewController

        //
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self

        puzzleBox.addGestureRecognizer(panGesture)
        view.addSubview(puzzleBox)
    }


    override func  viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()


        // MasterVC and DetailVC are both always visible on iPad.
        //
        if  UIDevice.isIPad  {
            splitViewController?.preferredDisplayMode = .allVisible
        }

        presentWordSearchPuzzle()


        // Become delegate for the UINavigationController interactive pop gesture
        //   when in Portait orientation, so it can be managed vis-a-vis panGesture
        //   during puzzle play to prevent swipe-right from invoking a segue-back
        //   to MasterVC from DetailVC -- in this case, there is also a
        //   UINavigationBar button available for segue-back.
        // See gestureRecognizerShouldBegin(:).
        //
        navconInteractivePopGesture?.delegate = nil
        navconInteractivePopGesture = nil

        if  let  splitVC = splitVC,
            splitVC.detailIsNavigationController,
            let  popGesture  = splitVC.detailAsNavigationController.interactivePopGestureRecognizer
        {
            navconInteractivePopGesture = popGesture
            navconInteractivePopGesture!.delegate = self
        }
    }


    // Each UIPuzzleElement is captured by two pointers: from characterDisplayGrid and from puzzleBox.subviews.
    // ASSUME that destroying them in one place, destroys them everywhere.
    //
    func  destroyCharacterDisplayGrid()
    {
        characterDisplayGrid.forEach  { $0.forEach  { $0.destroy() } }
        characterDisplayGrid  = []

        // ASSUME  All UIPuzzleElements are contained by characterDisplayGrid[][]
        //         and displayed within puzzleBox, which contains nothing else.
        //
        assert(puzzleBox.subviews.count <= 0)
    }


    deinit  {
        destroyCharacterDisplayGrid()
        panGesture.isEnabled  = false
    }



    //------------------------------------------------------------ -o-
    // MARK: - Helper methods.

    /**
     * Define DetailVC for single puzzle.
     *
     * Invoked by MasterVC in a variety of contexts across all devices and orientations and rotations:
     *   * In prepare() for UINavigationController
     *   * Via UINavigationItem.rightBarButtonItem action
     *   * PuzzleMasterVC.viewWillAppear()
     *   * UISplitViewControllerDelegate.targetDisplayModeForAction()
     */
    func  intakeWordSearchPuzzle(_ puzzle: WordSearchPuzzle, isLastPuzzle: Bool)
    {
        guard  puzzle != wordSearchPuzzle  else {
            Log.info("Puzzle is already active.  Skipping unnecessary update...")
            return
        }

        Log.info("Updating PuzzleDetailVC with new WordSearchPuzzle.")


        //
        if  (wordSearchPuzzle != nil) && (characterDisplayGrid.count > 0)
        {
            destroyCharacterDisplayGrid()
        }


        //
        wordSearchPuzzle    = puzzle
        self.isLastPuzzle   = isLastPuzzle
        isPuzzleSolved      = false

        guard let  wsp = wordSearchPuzzle  else {
            Log.fatal("FAILED TO INTAKE new WordSearchPuzzle.")
            return
        }


        //
        characterDisplayGrid = Array(
                                    repeatingUnique:  Array(repeatingUnique:UIPuzzleElement(asChildOf:puzzleBox), count: wsp.gridDimentions.columns),
                                    count:            wsp.gridDimentions.rows
                                )


        // Do not wait for view controller lifecycle to present when
        //   Navigation Controller is not driving relationship between
        //   MasterVC and DetailVC.
        //
        if let  splitVC = splitVC,  !splitVC.detailIsNavigationController  {
            presentWordSearchPuzzle()
        }
    }


    func  presentWordSearchPuzzle()
    {
        guard let  wsp = wordSearchPuzzle  else {
            try!  Log.error("wordSearchPuzzle IS UNDEFINED.")
            return
        }


        // Disable UISplitViewController gesture that presents MasterVC overlay, until puzzle is solved.
        // Otherwise, the overlay may block panGesture for horizontal words, such as on iPhoneXSMax in landscape.
        // See handlePanGesture(:).
        //
        splitVC?.presentsWithGesture = false

        // Clear gesture state data in case previous gesture did not have a proper .ending.
        UIPuzzleElement.clearArrayOfHitViews()


        // Set to non-zero only when top of puzzleBox might trigger System Notification modal view.
        // Creating a buffer space between the top of puzzleBox view will prevent accidentally
        //   drawing down the modal view when selecting a word that begins in the top row.
        // Per experiments with iPad in Simulator, this buffer is not required.
        //
        var  topBufferToPreventTriggeringSystemNotificationModalView  = CGFloat(0)

        if     !(splitVC?.detailIsNavigationController)!
            && UIDevice.current.orientation.isLandscape
            && !UIDevice.isIPad
        {
            topBufferToPreventTriggeringSystemNotificationModalView = (splitVC?.masterAsNavigationController.navigationBar.frame.height)!
        }


        // Establish frame and position of WordSearchPuzzle.
        // Update UIPuzzleElement class state.
        // Update scope of pan gesture recognizer.
        //
        let  saInsets  = view.safeAreaInsets

        let  puzzleWidth    = view.bounds.size.width    - saInsets.left - saInsets.right
        let  puzzleHeight   = view.bounds.size.height   - saInsets.top - saInsets.bottom - topBufferToPreventTriggeringSystemNotificationModalView
        let  puzzleX        = view.bounds.origin.x      + saInsets.left
        let  puzzleY        = view.bounds.origin.y      + saInsets.top

        puzzleBoxSideLength  = min(puzzleWidth, puzzleHeight)
        puzzleBoxCenter      = CGPoint( x:(puzzleX + (puzzleWidth / 2)), y:(puzzleY + (puzzleHeight / 2) + topBufferToPreventTriggeringSystemNotificationModalView) )

        puzzleBox.frame      = CGRect(origin:CGPoint.zero, size:CGSize(width:puzzleBoxSideLength, height:puzzleBoxSideLength))
        puzzleBox.center     = puzzleBoxCenter

        puzzleBox.backgroundColor = UIPuzzleConstants.dlColorDarkBlue


        // Define and position one instance of UIPuzzleElement for each character in wordSearchPuzzle.gridCharacters[][].
        //   First, compute shared variables based upon dimentions of puzzleBox and wordSearchPuzzle.
        //   Second, populate characterDisplayGrid with UIPuzzleElements.
        //
        UIPuzzleElement.classUpdate(puzzleBoxSideLength:puzzleBoxSideLength, wordSearchPuzzle:wsp)

        //
        var  heightDisplayOffset  = CGFloat(UIPuzzleElement.vspElementOffsets.height)

        for rowIndex in 0..<wsp.gridDimentions.rows
        {
            var  widthDisplayOffset  = CGFloat(UIPuzzleElement.vspElementOffsets.width)

            for columnIndex in 0..<wsp.gridDimentions.columns
            {
                let  thisCharacterDisplayLabel  = characterDisplayGrid[rowIndex][columnIndex]

                thisCharacterDisplayLabel.instanceUpdate(gridPosition:(columnIndex, rowIndex), isGridSquare:wsp.isGridSquare)
                thisCharacterDisplayLabel.frame.origin  = CGPoint(x:widthDisplayOffset, y:heightDisplayOffset)

                widthDisplayOffset += CGFloat(UIPuzzleElement.vspElementInterstitialBufferSize + UIPuzzleElement.vspElementWidth)


                // Use the following to DEBUG exception cases in UIPuzzleElement.
                //
                //thisCharacterDisplayLabel.instanceUpdate(gridPosition:(columnIndex + (Int.random(in:0...1) * 100), rowIndex))   //DEBUG
            }

            heightDisplayOffset += CGFloat(UIPuzzleElement.vspElementInterstitialBufferSize + UIPuzzleElement.vspElementHeight)
        }

    }


    /**
     *  The existing heuristic for selecing UIPuzzleElements via the panGesture is protective
     *  and sometimes skips elements that have clearly been visited by a touch.  This method checks
     *  for gaps between any two selections and, if they are in a straight line (horizontal, vertical
     *  or diagonal), the missing elements in the gaps are filled-in, in the proper order.
     */
    func  computeSkippedList(to puzzleElement: UIPuzzleElement)  -> [UIPuzzleElement]
    {
        if  UIPuzzleElement.arrayOfHitViews.isEmpty  { return [] }

        //
        let  lastCoordinate  = (UIPuzzleElement.arrayOfHitViews.last?.puzzlePoint)!
        let  newCoordinate   = puzzleElement.puzzlePoint

        let  differenceCoordinate  = WordSearchPuzzle.PuzzlePoint(
                                        column:  newCoordinate.column - lastCoordinate.column,
                                        row:     newCoordinate.row - lastCoordinate.row
                                     )

        var  iterationCoordinate  :WordSearchPuzzle.PuzzlePoint
        var  iterationDirection   = 1

        var  skippedList  = [UIPuzzleElement]()


        //
        iterationCoordinate = lastCoordinate

        // Add missing elements on the diagonal.
        //
        if  (abs(differenceCoordinate.column) > 1) && (differenceCoordinate.column == differenceCoordinate.row)
        {
            if  newCoordinate.column < lastCoordinate.column  { iterationDirection = -1 }

            repeat {
                iterationCoordinate.column  += iterationDirection
                iterationCoordinate.row     += iterationDirection
                skippedList.append(characterDisplayGrid[iterationCoordinate.row][iterationCoordinate.column])

            } while  iterationCoordinate != newCoordinate


        // Add missing elements in the column.
        //
        } else if  (abs(differenceCoordinate.column) > 1) && (differenceCoordinate.row == 0)
        {
            if  newCoordinate.column < lastCoordinate.column  { iterationDirection = -1 }

            repeat {
                iterationCoordinate.column += iterationDirection

                skippedList.append(characterDisplayGrid[iterationCoordinate.row][iterationCoordinate.column])

            } while  iterationCoordinate != newCoordinate


        // Add missing elements in the row.
        //
        } else if  (abs(differenceCoordinate.row) > 1) && (differenceCoordinate.column == 0)
        {
            if  newCoordinate.row < lastCoordinate.row  { iterationDirection = -1 }

            repeat {
                iterationCoordinate.row += iterationDirection

                skippedList.append(characterDisplayGrid[iterationCoordinate.row][iterationCoordinate.column])

            } while  iterationCoordinate != newCoordinate
        }


        //
        return  skippedList
    }



    //------------------------------------------------------------ -o-
    // MARK: - UIPanGestureRecognizer and Touch Events: Game lifecycle.

    /// Beginning of word selection gesture.
    ///
    override func  touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let  touch  = touches.first  else {
            try!  Log.error("FAILED TO ACQUIRE touches.")
            return
        }

        // Be sure each new selection always starts from from scratch.
        //
        UIPuzzleElement.clearArrayOfHitViews()


        //
        let     puzzleBoxLocation    = touch.location(in:puzzleBox)

        if let  hitView              = puzzleBox.hitTest(puzzleBoxLocation, with:nil),
           let  puzzleElement        = hitView as? UIPuzzleElement           // Consider only UIPuzzleElements
        {
            puzzleElement.isSelected = true
            UIPuzzleElement.arrayOfHitViews.append(puzzleElement)
        }
    }


    /**
     *  Be sure all incomplete selections are cleared, even when panGesture is not triggered.
     *
     *  ASSUMES that all WordSearchPuzzle target words have a length of two letters or greater.
     */
    override func  touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        UIPuzzleElement.clearArrayOfHitViews()
    }


    /**
     *  Middle and end of word selection gesture.
     *  Validate selected words and serve as one of two primary pivots for WordSearchPuzzle game lifcycle.
     *  See also `PuzzleMasterVC.segueButtonAction(sender:)`.
     *
     *  Allow `touchesBegain(::)` to initialize state at the beginning of any `handlePanGesture(:)`.
     *
     *  # WORD SELECTION
     *
     *  `UIView.hitTest` is bounded to `puzzleBox` and filtered for hits only to `UIPuzzleElement` objects.
     *
     *  Each hit is further constrained to a radius around the `.center` as a simple means
     *    to improve the accuracy of selecting words, especially for diagonals.
     *    Though, this restriction is discarded when the puzzle is not square.
     *
     *  The first element in a word selection is not bound by this limitation
     *    in order to make it easier to aquire with an imperfect touch.
     *
     *  # GAME LIFECYCLE
     *
     *  Once a puzzle is solved, MasterVC is updated allowing the user to advance to the next puzzle.
     *  In the case of solving tha last puzzle, the user may restart the entire puzzle group.
     */
    @objc func  handlePanGesture(_ sender: UIGestureRecognizer)
    {
        let     puzzleBoxLocation    = sender.location(in:puzzleBox)

        if let  hitView              = puzzleBox.hitTest(puzzleBoxLocation, with:nil),
           let  puzzleElement        = hitView as? UIPuzzleElement,           // Consider only UIPuzzleElements
                puzzleElement       != UIPuzzleElement.arrayOfHitViews.last   // Ignore consecutive duplicates.
        {
            // Only accept the hit if it is wihin a radius around the center of UIPuzzleElement...
            //   ...except for the first element for which any touch to it is acceptable.
            //
            // Allow backtracking: If the user overshoots the correct sequence, allow extra puzzleElements
            //   to be removed from the array if they are re-traversed in the reverse order.
            //
            // Fill in the gaps: If there is a gap between two elements, even though panGesture has been continuous,
            //   fill in those elements if they represent a straight line between two points on a horizontal,
            //   vertical or diagonal.
            //
            if     UIPuzzleElement.arrayOfHitViews.isEmpty
                || (puzzleElement.frame.origin.distance(to:puzzleBoxLocation) <= puzzleElement.hitRadius)
            {
                let  skippedList  = computeSkippedList(to:puzzleElement)

                //
                if     (UIPuzzleElement.arrayOfHitViews.count >= 2)
                    && (puzzleElement == UIPuzzleElement.arrayOfHitViews[UIPuzzleElement.arrayOfHitViews.count - 2])
                {
                    let  previousElement  = UIPuzzleElement.arrayOfHitViews.popLast()
                    previousElement?.isSelected = false

                } else if  !puzzleElement.isSelected
                {
                    if  !skippedList.isEmpty
                    {
                        skippedList.forEach {
                            $0.isSelected = true
                            UIPuzzleElement.arrayOfHitViews.append($0)
                        }

                    } else {
                        puzzleElement.isSelected = true
                        UIPuzzleElement.arrayOfHitViews.append(puzzleElement)
                    }
                }
            }
        }


        //
        if  sender.state == .ended
        {
            var  puzzleElementSequence  = UIPuzzleElement.arrayOfHitViews.map { $0.puzzlePoint }
            var  gridCharacterSequence  = UIPuzzleElement.arrayOfHitViews.map { $0.text! }.joined(separator:"")


            // Look for selected word, whether forwards or backwards.
            //
            var  isSelectionATargetWord  = wordSearchPuzzle?.validateTargetWord(forSelectedWord:gridCharacterSequence, withPuzzlePointSequence:puzzleElementSequence)

            if  !isSelectionATargetWord! && (puzzleElementSequence.count > 1)
            {
                gridCharacterSequence = String(gridCharacterSequence.reversed())
                puzzleElementSequence.reverse()

                isSelectionATargetWord  = wordSearchPuzzle?.validateTargetWord(forSelectedWord:gridCharacterSequence, withPuzzlePointSequence:puzzleElementSequence)
            }


            //
            if  isSelectionATargetWord!
            {
                UIPuzzleElement.arrayOfHitViews.forEach  {
                    $0.isSelected = false
                    $0.isMatched = true
                }

                // Trigger update to MasterVC if it is simultaneously visible with DetailVC.
                //
                if  UIDevice.isIPad  {
                    splitViewController?.preferredDisplayMode = .primaryOverlay
                }

                if  !isPuzzleSolved && wordSearchPuzzle!.isPuzzleSolved
                {
                    isPuzzleSolved = true   // Announce the solution only once!
                    announcePuzzleGameWin()

                    // Re-enable UISplitViewController gesture that presents MasterVC.
                    // See presentWordSearchPuzzle().
                    //
                    splitVC?.presentsWithGesture = true
                }
            }

            UIPuzzleElement.clearArrayOfHitViews()
        }
    }


    func  announcePuzzleGameWin()
    {
        if  isLastPuzzle  {
            Log.info("ALL WordSearchPuzzles have BEEN SOLVED.")
            puzzleWinAlert = UIAlertController(title:kAlertAllPuzzlesSolvedTitle, message:kAlertAllPuzzlesSolvedMessage, preferredStyle:.alert)
        } else {
            Log.info("This WordSearchPuzzle has BEEN SOLVED.")
            puzzleWinAlert = UIAlertController(title:nil, message:kAlertOnePuzzleSolvedMessage, preferredStyle:.alert)
        }


        // Help the alert to standout by not reflecting the colors beneath it.
        //
        puzzleWinAlert?.getAlertSubview().backgroundColor = UIColor.white

        // When MasterVC is hidden, proactively update before it is shown.
        // In particular, this prevents label jitter in UINavigationItem.rightBarButtonItem.
        //
        if let  splitVC = splitVC,  splitVC.detailIsNavigationController
        {
            let  masterVC  = splitVC.masterAsNavigationController.viewControllers.first as! PuzzleMasterVC
            masterVC.updateView()
        }


        //
        self.present(puzzleWinAlert!, animated:false)
        {
            //NB  tapGesture, embedded in composite view of the alert object, will be discarded when the alert object is dismissed.
            //
            let  tapGesture  = UITapGestureRecognizer(target:self, action:#selector(self.dismissPuzzleGameWinAnnouncement))
            self.puzzleWinAlert!.view.superview?.addGestureRecognizer(tapGesture)
        }
    }


    @objc func  dismissPuzzleGameWinAnnouncement()
    {
        self.dismiss(animated:true, completion:nil)
    }



    //------------------------------------------------------------ -o-
    // MARK: - UIGestureRecognizerDelegate.

    func  gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        // Avoid segue-back to MasterVC via Navigation Controller swipe-right gesture when in portrait mode.
        // NB  navconInteractivePopGesture is selected in viewWillAppear(:).
        //
        if      (gestureRecognizer == navconInteractivePopGesture)
            &&  UIDevice.current.orientation.isPortrait
            &&  !(wordSearchPuzzle?.isPuzzleSolved)!
        {
            return false
        }

        return  true
    }

}

