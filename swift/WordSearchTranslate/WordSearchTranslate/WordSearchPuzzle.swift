//
// WordSearchPuzzle.swift
//
//
// For an overview of this module and WordSearchPuzzleGroup.swift, see
//   header documentation in WordSearchPuzzleGroup.swift.
//
//
//---------------------------------------------------------------------
//     Copyright (C) 2019 David Reeder.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

import Foundation




//------------------------------------------------- -o--
// MARK: -

/**
 * Errors that may occur while ingesting or managing WordSearchPuzzle data.
 *
 * Each case may return a detailed explanation.
 */

enum  WordSearchPuzzleError  : Error
{
    // Parse errors.
    case  inputIsCorrupt(_:String)

    // Usage errors.
    case  pointOutOfRange(puzzlePoint:WordSearchPuzzle.PuzzlePoint, gridDimentions:WordSearchPuzzle.GridDimentions)
}




//------------------------------------------------- -o--
// MARK: -

/**
 *  Ingest and manage lifecycle of WordSearchPuzzle.
 *
 *  Initialize from JSON.
 *  Support puzzle character lookups and word selection lookups.
 *  Allow puzzle to be played multiple times.
 */

class  WordSearchPuzzle  : CustomStringConvertible, Equatable
{
    //----------------------------------------------------------- -o-
    // MARK: Type definitions.

    typealias  PuzzlePoint     = (column: Int, row: Int)
    typealias  GridDimentions  = (columns: Int, rows: Int)



    //----------------------------------------------------------- -o-
    // MARK: - Constants.

    private let  kJSONSourceLanguage    = "source_language"
    private let  kJSONSourceWord        = "word"
    private let  kJSONTargetLanguage    = "target_language"
    private let  kJSONTargetWords       = "word_locations"
    private let  kJSONGridCharacters    = "character_grid"



    //----------------------------------------------------------- -o-
    // MARK: - Properties.

    let  sourceLanguage  :String
    let  sourceWord      :String

    let  targetLanguage  :String
    let  targetWords     :[String:String]


    //
    var  targetWordsValues  :[String]  { return  Array(targetWords.values) }

    /**
     *  Maintained as a dictionary of keys taken from `targetWords.values`,
     *  where each key has a **Bool** value of `true` for matched, `false` unmatched.
     */
    private var  targetWordsMatched  = [String:Bool]()   //INITIAL

    var  numberOfUnmatchedWords  :Int
    {
        var  countOfMatchedWords  = 0
        targetWordsMatched.values.forEach  { if $0 { countOfMatchedWords += 1 } }

        return  targetWords.count - countOfMatchedWords
    }

    var  unmatchedWords  :[String]
    {
        var  unmatchedWordList  = [String]()

        targetWordsValues.forEach  {
            if  let  thisWord  = targetWordsMatched[$0],  !thisWord  {
                unmatchedWordList.append($0)
            }
        }

        if  unmatchedWordList.isEmpty  {
            unmatchedWordList.append("(none)")
        }

        return  unmatchedWordList
    }

    var  isPuzzleSolved  :Bool  {
        return  numberOfUnmatchedWords == 0
    }

    var  isPuzzleNew  :Bool  {
        return  targetWords.count == numberOfUnmatchedWords
    }


    //
    let  gridDimentions      :GridDimentions
    let  gridCharacters      :[ [String] ]

    var  isGridSquare  :Bool  {
        return  gridDimentions.rows == gridDimentions.columns
    }


    /// Generate verbose output.  Primarily for unit tests.
    static var  verbose  = false


    //
    var  description  :String
    {
        var  gridArrayString  = ""

        for row in gridCharacters  {
            gridArrayString += "\n\t\t"
            for element in row  {
                gridArrayString += element + " "
            }
        }

        //
        return  """
                \nINSTANCE OF \(Log.filename())--
                    sourceLanguage  = \(sourceLanguage)
                    sourceWord      = \(sourceWord)
                    targetLanguage  = \(targetLanguage)
                    targetWords     = \(targetWordsValues.joined(separator:" "))
                    gridDimentions  = \(gridDimentions)
                    gridCharacters  = ...\(gridArrayString)
                    .
                    isPuzzleSolved         = \(isPuzzleSolved)
                    isPuzzleNew            = \(isPuzzleNew)
                    isGridSquare           = \(isGridSquare)
                    numberOfUnmatchedWords = \(numberOfUnmatchedWords)
                    unmatchedWords         = \(unmatchedWords)
                """
    }



    //----------------------------------------------------------- -o-
    // MARK: - Lifecycle.

    /**
     * Parse JSON input.
     *
     * See WordSearchPuzzleGroup header for assumptions about the
     * structure of the input file.
     *
     * On error, THROWS WordSearchPuzzleError.inputIsCorrupt().
     */
    init?(withJSON json: [String:Any])  throws
    {
        var  errorMessage  = ""


        //
        sourceLanguage  = json[kJSONSourceLanguage]     as? String ?? ""
        sourceWord      = json[kJSONSourceWord]         as? String ?? ""

        //
        targetLanguage  = json[kJSONTargetLanguage]     as? String ?? ""
        targetWords     = json[kJSONTargetWords]        as? [String:String] ?? [:]

        for (_,value) in targetWords  {
            targetWordsMatched[value] = false
        }


        //
        gridCharacters = json[kJSONGridCharacters] as? [[String]] ?? [[]]

        gridDimentions.columns  = gridCharacters[0].count
        gridDimentions.rows     = gridCharacters.count


        // Very simple sanity checks.
        //
        // (See WordSearchPuzzleGroup header for assumptions about the structure
        //   of the input file.)
        //
        if  (sourceLanguage.count <= 0) || (sourceWord.count <= 0)  {
            errorMessage = "FAILED TO POPULATE sourceLanguage or sourceWord."

        } else if  (targetLanguage.count <= 0) || (targetWords.count <= 0)  {
            errorMessage = "FAILED TO POPULATE targetLanguage or targetWords."

        } else if  (gridDimentions.columns <= 0) || (gridDimentions.rows <= 0)  {
            errorMessage = "FAILED TO POPULATE gridCharacters."
        }


        // Return status.
        //
        guard  errorMessage.isEmpty  else {
            try  Log.error(errorMessage, WordSearchPuzzleError.inputIsCorrupt(Log.context() + errorMessage))
            return  nil
        }

        if  WordSearchPuzzle.verbose  { Log.debug(description) }
    }



    //----------------------------------------------------------- -o-
    // MARK: - Public methods.

    func  characterAt(puzzlePoint pp: PuzzlePoint)  throws -> String
    {
        try  validate(puzzlePoint:pp)
        return  gridCharacters[pp.row][pp.column]
    }


    func  validateTargetWord(forSelectedWord word: String, withPuzzlePointSequence ppSequence: [PuzzlePoint])  -> Bool
    {
        let  separatorString            = ","
        let  puzzlePointArrayAsString   = ppSequence.map { String($0.column) + separatorString + String($0.row) }.joined(separator:separatorString)

        guard let  wordIndex = targetWords[puzzlePointArrayAsString]  else {
            Log.info("Selected sequence does not exist in targetWords dictionary.  (\(puzzlePointArrayAsString))")
            return  false
        }

        guard  wordIndex == word  else {
            Log.info("Word does not match PuzzlePoint sequence.  (\(word))")
            return  false
        }

        Log.info("Found \"\(word)\" at coordinates \(puzzlePointArrayAsString).")
        targetWordsMatched[wordIndex] = true

        return  true
    }


    func  resetPuzzleToUnsolved()
    {
        targetWords.values.forEach  { targetWordsMatched[$0] = false }
    }



    //----------------------------------------------------------- -o-
    // MARK: - Private methods.

    /**
     *  Validate that given PuzzlePoint is within range of gridDimentions.
     *
     *  On error, THROWS WordSearchPuzzleError.pointOutOfRange().
     */
    private func  validate(puzzlePoint pp: PuzzlePoint)  throws
    {
        guard  pp.row >= 0,    pp.row < gridDimentions.rows,
               pp.column >= 0, pp.column < gridDimentions.columns

        else {
            try  Log.error( "PuzzlePoint OUT OF RANGE.  (pp: \(pp)  grid:\(gridDimentions))",
                            WordSearchPuzzleError.pointOutOfRange(puzzlePoint:pp, gridDimentions:gridDimentions) )
            return
        }
    }



    //----------------------------------------------------------- -o-
    // MARK: - Equatable.

    static func  ==(_ left: WordSearchPuzzle, _ right: WordSearchPuzzle)  -> Bool
    {
        return     (left.sourceLanguage  == right.sourceLanguage)
                && (left.sourceWord      == right.sourceWord)
                && (left.targetLanguage  == right.targetLanguage)
                && (left.targetWords     == right.targetWords)
                && (left.gridCharacters  == right.gridCharacters)
    }

}

