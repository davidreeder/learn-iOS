//
// PuzzleSettingsVC.swift
//
//
//---------------------------------------------------------------------
//     Copyright (C) 2019 David Reeder.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

import  Foundation
import  UIKit




//------------------------------------------------------------ -o--
// MARK: -

/**
 *  Manage content of displayed popup allowing user to configure game play and information display.
 */

class  PuzzleSettingsVC  : UIViewController
{
    //------------------------------------------------------------ -o-
    // MARK: Constants.

    let  kPopupViewSizeBuffer       = CGFloat(30)

    let  kPopupLabelSystemFontSize  = CGFloat(16)

    let  kPopupOutletBorderWidth    = CGFloat(2)
    let  kPopupOutletCornerRadius   = CGFloat(6)



    //------------------------------------------------------------ -o-
    // MARK: - IB Outlets.

    @IBOutlet weak var stackViewOutlet: UIStackView!

    //
    @IBOutlet weak var  puzzleIterationLabel            :UILabel!
    @IBOutlet weak var  puzzleIterationSegCtrlOutlet    :UISegmentedControl!

    @IBOutlet weak var  displayTranslationLabel           :UILabel!
    @IBOutlet weak var  displayTranslationSegCtrlOutlet   :UISegmentedControl!



    //------------------------------------------------------------ -o-
    // MARK: - Properties.

    let  settings  = Settings.shared



    //------------------------------------------------------------ -o-
    // MARK: - Lifecycle.

    // NB  All parameters seem to work reasonably well for both phones and pads.
    //
    override func  viewDidLoad()
    {
        super.viewDidLoad()

        view.backgroundColor = UIPuzzleConstants.dlColorLightGreen

        //
        puzzleIterationLabel.textColor  = UIPuzzleConstants.dlColorDarkBrown
        puzzleIterationLabel.font       = UIFont.boldSystemFont(ofSize:kPopupLabelSystemFontSize)

        puzzleIterationSegCtrlOutlet.backgroundColor    = UIPuzzleConstants.dlColorLightPurple
        puzzleIterationSegCtrlOutlet.tintColor          = UIPuzzleConstants.dlColorDarkBlue

        puzzleIterationSegCtrlOutlet.layer.borderWidth   = kPopupOutletBorderWidth
        puzzleIterationSegCtrlOutlet.layer.cornerRadius  = kPopupOutletCornerRadius
        puzzleIterationSegCtrlOutlet.layer.borderColor   = UIPuzzleConstants.dlColorDarkBlue.cgColor

        //
        displayTranslationLabel.textColor   = UIPuzzleConstants.dlColorDarkBrown
        displayTranslationLabel.font        = UIFont.boldSystemFont(ofSize:kPopupLabelSystemFontSize)

        displayTranslationSegCtrlOutlet.backgroundColor  = UIPuzzleConstants.dlColorLightPurple
        displayTranslationSegCtrlOutlet.tintColor        = UIPuzzleConstants.dlColorDarkBlue

        displayTranslationSegCtrlOutlet.layer.borderWidth   = kPopupOutletBorderWidth
        displayTranslationSegCtrlOutlet.layer.cornerRadius  = kPopupOutletCornerRadius
        displayTranslationSegCtrlOutlet.layer.borderColor   = UIPuzzleConstants.dlColorDarkBlue.cgColor
    }

    override func  viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()

        // NB  Naive use of UIFontMetrics conflicts with preferredContentSize by presenting text
        //     that does not wrap and strays beyond the boundaries of the popup view.
        //     In this case, the performance of preferredContentSize is given priority.
        //
        if let  smallestSize  = stackViewOutlet?.sizeThatFits(UIView.layoutFittingCompressedSize)  {
            preferredContentSize = CGSize( width:  smallestSize.width   + kPopupViewSizeBuffer,
                                           height: smallestSize.height  + kPopupViewSizeBuffer )
        }

        puzzleIterationSegCtrlOutlet.selectedSegmentIndex     = settings.puzzleIterationMethod.rawValue
        displayTranslationSegCtrlOutlet.selectedSegmentIndex  = settings.displayTranslation.rawValue



        // Provide a means to dismiss the SettingsVC popup
        //   when presented on iPhoneXSMax in landscape orientation.
        //
        // TBD  Tap gesture should be received outside the popup,
        //      to be consistent with all other instances of SettingsVC popup.
        //
        if  let  detailIsNavcon  = settings.splitVC?.detailIsNavigationController,
            !detailIsNavcon,
            !UIDevice.isIPad
        {
            let  tapGesture  = UITapGestureRecognizer(target:self, action:#selector(self.dismissSelf))
            self.view.addGestureRecognizer(tapGesture)
        }
    }


    @objc func  dismissSelf()  {
        self.dismiss(animated:true, completion:nil)
    }



    //------------------------------------------------------------ -o-
    // MARK: - IB Actions.

    @IBAction func  puzzleIterationSegCtrlAction(_ sender: UISegmentedControl, forEvent event: UIEvent)
    {
        guard  WordSearchPuzzleGroup.iterationMethodRange.contains(sender.selectedSegmentIndex)  else {
            try!  Log.error("puzzleOrderSegCtrlAction returned index OUT OF RANGE.")
            return
        }

        settings.puzzleIterationMethod = WordSearchPuzzleGroup.IterationMethod(rawValue:sender.selectedSegmentIndex)!
    }


    @IBAction func  displayTranslationSegCtrlAction(_ sender: UISegmentedControl, forEvent event: UIEvent)
    {
        guard  Settings.displayTranslationRange.contains(sender.selectedSegmentIndex)  else {
            try!  Log.error("translationGivenSegCtrlAction returned index OUT OF RANGE.")
            return
        }

        settings.displayTranslation = Settings.DisplayTranslation(rawValue:sender.selectedSegmentIndex)!

        if let  masterVC = settings.splitVC?.masterAsNavigationController.topViewController as? PuzzleMasterVC
        {
            masterVC.updateView()
        }
    }

}
