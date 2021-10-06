//
// UIPuzzleElement.swift
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
 * Encapsulate the individual and collection characteristics of the display of each character element in the puzzle grid.
 * Parameters are divided into updates for the class (collection) and updates for each instance.
 *
 * This class represents an imperfect division of labor between the calling environment and the puzzle element instances.
 * The class properties MUST be updated from the calling environment after each rotation prior to updating the instances.
 *
 * All view-specific parameters are initially undefined.
 * Public parameters are static for sharing amongst other classes.
 * Private parameters are static for sharing between instances of this class.
 */
class  UIPuzzleElement  : UILabel
{
    //------------------------------------------------------------ -o-
    // MARK: Private typealiases.

    // Shorthand to improve readability in some sections.
    //
    private typealias  pe  = UIPuzzleElement



    //------------------------------------------------------------ -o-
    // MARK: - Private constants.

    private let  backgroundColorChosen  = UIPuzzleConstants.dlColorDarkRed
    private let  backgroundColorNormal  = UIPuzzleConstants.dlColorLightOrange



    //------------------------------------------------------------ -o-
    // MARK: - Public, view-specific parameters.  Shared amongst other classes.

    /// Offset from edges of enclosing puzzle view (puzzleBox).
    static var  vspElementOffsets  = ( width:CGFloat(UIPuzzleConstants.undefinedCGFloat), height:CGFloat(UIPuzzleConstants.undefinedCGFloat) )

    /// Distance between element instances.
    static var  vspElementInterstitialBufferSize  :CGFloat = UIPuzzleConstants.undefinedCGFloat

    /// Width and height of each element.
    static var  vspElementWidth   :CGFloat = UIPuzzleConstants.undefinedCGFloat
    static var  vspElementHeight  :CGFloat = UIPuzzleConstants.undefinedCGFloat



    //------------------------------------------------------------ -o-
    // MARK: - Private, view-specific parameters.  Shared between instances.

    /// Side length of enclosing puzzle view.
    private static var  vspPuzzleBoxSideLength  :CGFloat = UIPuzzleConstants.undefinedCGFloat

    /// Used to capture the character in a given column and row, and the number of columns and rows.
    private static var  vspWordSearchPuzzle     :WordSearchPuzzle?

    /// `frame.size` of element instance.
    private static var  vspElementSize  = CGSize.zero

    /// Values for other characteristics of element display.
    private static var  vspFontSize       :CGFloat = UIPuzzleConstants.undefinedCGFloat
    private static var  vspBorderWidth    :CGFloat = UIPuzzleConstants.undefinedCGFloat
    private static var  vspCornerRadius   :CGFloat = UIPuzzleConstants.undefinedCGFloat



    //------------------------------------------------------------ -o-
    // MARK: - Properties.

    /// Logical coordinates for this element amongst the collection of all elements in the puzzle grid.
    var  puzzlePoint  = WordSearchPuzzle.PuzzlePoint(-1,-1)   //DEFAULT is undefined.

    /// Set/check between classUpdate() and instanceUpdate() to help maintain consistency of parameter updates.
    static var  currentOrientation  = UIDevice.current.orientation


    /// `true` if element is selected during a given search gesture.
    /// Cleared if the word that includes this element is not matched.
    var  isSelected  = false  { didSet  { setBackgroundColor(isSelected || isMatched) } }

    /// `true` if element is part of a puzzle word that has been matched.
    /// Persists across gestures.
    var  isMatched  = false   { didSet  { setBackgroundColor(isMatched) } }


    /// Ephemeral list of all elements captured by a given Pan Gesture.  This list is cleared (sometime) before each new gesture.
    static var  arrayOfHitViews  = [UIPuzzleElement]()


    /**
     * Radius around `UIPuzzleElement.center` within which a touch must occur in order to select this `UIPuzzleElement`.
     */
    var  hitRadius  :CGFloat = UIPuzzleConstants.undefinedCGFloat

    /// Arbitrary coefficient to narrow hitRadius.
    let  kHitRadiusDivisor  :CGFloat = 1.25


    //
    override var  description  :String
    {
        return  """
                \"\(text ?? "")\" @ (\(puzzlePoint.column),\(puzzlePoint.row))
                """
    }



    //------------------------------------------------------------ -o-
    // MARK: - Class lifecycle.

    /**
     * Update class properties per device type and current orientation.
     *
     * - Parameters:
     *    + puzzleBoxSideLength **:CGFloat**         -- Length of one side of the square view that contains all `UIPuzzleElement`s.
     *    + wordSearchPuzzle **:WordSearchPuzzle**   -- Provides logical width and height of WordSearchPuzzle and values for each gridCharacter.
     */
    static func  classUpdate(puzzleBoxSideLength: CGFloat, wordSearchPuzzle: WordSearchPuzzle)
    {
        pe.vspPuzzleBoxSideLength  = puzzleBoxSideLength
        pe.vspWordSearchPuzzle     = wordSearchPuzzle

        let  wsp  = pe.vspWordSearchPuzzle!

        pe.currentOrientation = UIDevice.current.orientation


        // Device specific properties.
        //
        if  UIDevice.isIPad
        {
            pe.vspElementOffsets                 = ( width:9, height:9 )
            pe.vspElementInterstitialBufferSize  = 8

            pe.vspFontSize      = 42
            pe.vspBorderWidth   = 5

            if  UIDevice.current.orientation.isPortrait  {
                pe.vspCornerRadius  = 20
            } else {
                pe.vspCornerRadius  = 30
            }

        } else {
            pe.vspElementOffsets                 = ( width:5, height:5 )
            pe.vspElementInterstitialBufferSize  = 3

            pe.vspFontSize      = 24
            pe.vspBorderWidth   = 2

            pe.vspCornerRadius  = 12
        }


        // Grid specific properties.
        //
        let  puzzleTotalWidthForAllElements   = pe.vspPuzzleBoxSideLength
                                                    - CGFloat(pe.vspElementOffsets.width * 2)
                                                    - (CGFloat(wsp.gridDimentions.columns - 1) * pe.vspElementInterstitialBufferSize)

        let  puzzleTotalHeightForAllElements  = pe.vspPuzzleBoxSideLength
                                                    - CGFloat(pe.vspElementOffsets.height * 2)
                                                    - (CGFloat(wsp.gridDimentions.rows - 1) * pe.vspElementInterstitialBufferSize)


        pe.vspElementWidth   = puzzleTotalWidthForAllElements  / CGFloat(wsp.gridDimentions.columns)
        pe.vspElementHeight  = puzzleTotalHeightForAllElements / CGFloat(wsp.gridDimentions.rows)

        pe.vspElementSize = CGSize(width:pe.vspElementWidth, height:pe.vspElementHeight)
    }


    static func  clearArrayOfHitViews()
    {
        arrayOfHitViews.forEach  { if !$0.isMatched { $0.isSelected = false } }
        arrayOfHitViews = [UIPuzzleElement]()
    }



    //------------------------------------------------------------ -o-
    // MARK: - Instance lifecycle.

    init(asChildOf parent: UIView)
    {
        super.init(frame: CGRect.zero)

        //
        textAlignment       = .center
        layer.borderColor   = UIPuzzleConstants.dlColorLightYellow.cgColor
        backgroundColor     = backgroundColorNormal

        clipsToBounds               = true
        isUserInteractionEnabled    = true

        parent.addSubview(self)
    }


    func  destroy()
    {
        isHidden = true
        removeFromSuperview()
    }


    deinit  { destroy() }


    /**
     * Update instance properties per device type and current orientation.
     *
     * - Parameters:
     *    + gridPosition **:WordSearchPuzzle.PuzzlePoint**   -- Logical coordinate of this element in the puzzle grid.
     */
    func  instanceUpdate(gridPosition: WordSearchPuzzle.PuzzlePoint, isGridSquare: Bool)
    {
        // Compare orientation setting between classUpdate(:) and instanceUpdate(::).
        //
        if  pe.currentOrientation != UIDevice.current.orientation
        {
            Log.fatal("INSTANCE INITIALIZATION REQUIRES that \(Log.filename()).classUpdate(::) must be run first.")
        }


        //
        frame.origin  = CGPoint.zero
        frame.size    = pe.vspElementSize

        puzzlePoint  = gridPosition

        do {
            text = try pe.vspWordSearchPuzzle?.characterAt(puzzlePoint: puzzlePoint)
        } catch {
            destroy()
            return
        }

        font = UIFont.preferredFont(forTextStyle:.body).withSize(pe.vspFontSize)

        layer.borderWidth   = pe.vspBorderWidth
        layer.cornerRadius  = pe.vspCornerRadius


        // If the grid is square, reduce the area of a valid hit to
        //   the minimum of the rectangle lengths, divided by an arbitrary factor.
        //
        hitRadius = min(frame.size.width, frame.size.height)

        if  isGridSquare  {
            hitRadius /= kHitRadiusDivisor
        }
    }


    func  setBackgroundColor(_ isChosen: Bool)
    {
        if  isChosen  {
            backgroundColor = backgroundColorChosen
        } else {
            backgroundColor = backgroundColorNormal
        }

    }



    //------------------------------------------------------------ -o-
    // MARK: - NSCoding.
    //
    // Required by class heirarchy.
    //

    required  init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)

        isSelected  = aDecoder.decodeBool(forKey: "isSelected")
        isMatched   = aDecoder.decodeBool(forKey: "isMatched")
    }


    override func  encode(with aCoder: NSCoder)
    {
        super.encode(with: aCoder)

        aCoder.encode(isSelected,  forKey: "isSelected")
        aCoder.encode(isMatched,   forKey: "isMatched")
    }

}
