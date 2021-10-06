//
// UnitTestsForModel.swift
//
//
//---------------------------------------------------------------------
//     Copyright (C) 2019 David Reeder.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

import  XCTest




//--------------------------------------------------- -o-
// MARK: -

/**
 *  Examples of Unit Tests.
 *
 *  High level tests of the model to demonstrate how input file errors are handled,
 *    compared to examples of healthy input files and alternate input files.
 */

class UnitTestsForModel: XCTestCase
{
    //--------------------------------------------------- -o-
    // MARK: Constants.

    let  separator  = "-------------------------------------------------------- -o" + "--"

    var  wspg               :WordSearchPuzzleGroup?
    var  wspgStatsOnError   :WordSearchPuzzleGroup.ValidationProcessingStats?



    //--------------------------------------------------- -o-
    // MARK: - Lifecycle.

    override func  setUp()
    {
        Log.postViaNSLog = false

        //
        wspg              = nil
        wspgStatsOnError  = nil

        Settings.shared.puzzleIterationMethod = .inOrder
        WordSearchPuzzle.verbose = true

        //
        print("\n" + separator)
    }

    override func  tearDown()
    {
        print(separator + "\n")
    }



    //--------------------------------------------------- -o-
    // MARK: - Tests.

    func  testEmptyFile()
    {
        Log.info("\n")

        let  filename  = "puzzleGroup--Testing2--emptyFile.txt"


        //
        (wspg, wspgStatsOnError) = validatePuzzle(from:filename)

        Log.info(wspgStatsOnError?.description ?? "NO STATISTICS DEMONSTRATING ERRORS.")


        //
        XCTAssertNil(wspg)
        XCTAssert(wspgStatsOnError?.jsonProcessingSuccess == 0)
    }


    func  testBrokenExamples()
    {
        Log.info("\n")

        let  filename  = "puzzleGroup--Testing1--brokenExamples.txt"


        //
        (wspg, wspgStatsOnError) = validatePuzzle(from:filename)

        Log.info(wspgStatsOnError?.description ?? "NO STATISTICS DEMONSTRATING ERRORS.")


        //
        XCTAssertNil(wspg)

        XCTAssert(wspgStatsOnError?.jsonProcessingSuccess == 0)
        XCTAssert(wspgStatsOnError?.jsonProcessingFailure == 8)
        XCTAssert(wspgStatsOnError?.emptyLines == 5)
    }


    func  testAlternateExamples()
    {
        Log.info("\n")

        let  filename  = "puzzleGroup--alternateExamples.txt"


        //
        (wspg, wspgStatsOnError) = validatePuzzle(from:filename)

        Log.info(wspgStatsOnError?.description ?? "NO STATISTICS DEMONSTRATING ERRORS.")


        //
        XCTAssertNotNil(wspg)
        XCTAssert(wspg?.validationProcessingStats.jsonProcessingSuccess == 4)
    }


    func  testMain()
    {
        Log.info("\n")

        let  filename  = "puzzleGroup--main.txt"


        //
        (wspg, wspgStatsOnError) = validatePuzzle(from:filename)

        Log.info(wspgStatsOnError?.description ?? "NO STATISTICS DEMONSTRATING ERRORS.")


        //
        XCTAssertNotNil(wspg)
        XCTAssert(wspg?.validationProcessingStats.jsonProcessingSuccess == 9)
    }



    //--------------------------------------------------- -o-
    // MARK: - Test Helper Methods.

    private func  validatePuzzle(from filename: String)  -> (WordSearchPuzzleGroup?, WordSearchPuzzleGroup.ValidationProcessingStats?)
    {
        var  wspg               :WordSearchPuzzleGroup?
        var  wspgStatsOnError   :WordSearchPuzzleGroup.ValidationProcessingStats?


        //
        do  {
            wspg  = try WordSearchPuzzleGroup(withFile:filename)

        } catch WordSearchPuzzleGroupError.validationFailure(let wspgStats) {
            wspgStatsOnError = wspgStats

        } catch {
            try!  Log.error("UNEXPECTED ERROR.")
        }


        //
        return  (wspg, wspgStatsOnError)
    }

}
