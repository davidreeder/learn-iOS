//
// WordSearchPuzzleGroup.swift
//
//
// INTENTION: 
//   * Download a set of WordSearchPuzzles so that they may be presented to the user.
//   * Puzzles may be presented in order or randomly.
//   * After user has solved all the puzzles, they may be reset and re-played again.
//   * Although WordSearchPuzzleGroup may be replaced at any time, 
//       only one set of puzzles may be played at a time.
// 
//
// PROCESSING STRATEGY:
//   * If any one line of the puzzle file fails to generate a
//       WordSearchPuzzle, it is ignored.
// 
//   * Though a download may generate errors along the way, the process of
//       fetching a new WordSearchPuzzleGroup is considered a success so long as
//       at least one WordSearchPuzzle is instantiated.
// 
//   * Error checking is kept to a minimum while ingesting the WordSearchPuzzleGroup because...
//       per the answers to my questions about this Programming Task I assume that
//       neither semantic nor syntactic errors will be introduced into the input file.  
//       In a production environment, presumably the input file would be checked by 
//       the distributing server or by some other quality assurance process.
//
//       Consequently, the input file ingestion code does not check for 
//       significant errors in the input file.
//
//       Otherwise, there are any number of errors we might check for, including:
//         + Do all expected fields exist and contain values?
//         + Are source_language and target_language real languages?
//         + Do all word_locations exist in character_grid?
//         + Do these words always read forward in the target language?
//         + Are all the coordinates of word_locations valid?
//         + Are all characters in character_grid valid?
// 
//
// STRUCTURAL ASSUMPTIONS about the input file:
//   * Input files are generated without errors.
// 
//   * The set of WordSearchPuzzles in a WordSearchPuzzleGroup are collected
//       according to some theme or lesson.
// 
//   * If the download of the WordSearchPuzzleGroup file is successful, it is
//       assumed that it should parse correctly and contain no logical errors.
// 
//   * The WordSearchPuzzleGroup file is ASCII encoded, where unicode
//       characters are presented per the JSON standard.
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
 * Errors that may occur while processing WordSearchPuzzleGroup data files.
 *
 * Each case may return a detailed explanation.
 */
enum  WordSearchPuzzleGroupError  : Error
{
    case  badInputArgument(_: String)
    case  downloadFailure(_: String)
    case  dataFileLoadFailure(_: String)
    case  validationFailure(_: WordSearchPuzzleGroup.ValidationProcessingStats)
}



//------------------------------------------------- -o--
// MARK: -

/**
 * Download a collection of `WordSearchPuzzle`s and manage its lifecycle.
 */

class  WordSearchPuzzleGroup  : CustomStringConvertible
{
    //----------------------------------------------------------- -o-
    // MARK: Public type definitions.

    enum  IterationMethod  :Int
    {
        case  inOrder = 0
        case  random
    }

    static let  iterationMethodRange  = IterationMethod.inOrder.rawValue...IterationMethod.random.rawValue


    //
    struct  ValidationProcessingStats  : CustomStringConvertible
    {
        var  lineCount              :Int = 0
        var  emptyLines             :Int = 0
        var  jsonProcessingFailure  :Int = 0
        var  jsonProcessingSuccess  :Int = 0

        var  errorMessage  = ""

        //
        var  description: String  {
            return  """
                    \nWSPGValidationProcessingStats--
                        lineCount               = \(lineCount)
                        emptyLines              = \(emptyLines)
                        jsonProcessingFailure   = \(jsonProcessingFailure)
                        jsonProcessingSuccess   = \(jsonProcessingSuccess)
                        .
                        errorMessage = \(errorMessage.isEmpty ? "(none)" : errorMessage)
                    """
        }
    }



    //----------------------------------------------------------- -o-
    // MARK: - Constants.

    static let  kDownloadWaitMaxInSeconds  = 5.0

    static let  kUndefinedIndex  = -1



    //----------------------------------------------------------- -o-
    // MARK: - Public properties.

    var  settings  :Settings  = Settings.shared


    //
    var  dataFileOrURLString  :String

    var  iterationMethod  :WordSearchPuzzleGroup.IterationMethod  {
        return settings.puzzleIterationMethod
    }


    //
    var  currentPuzzle  :WordSearchPuzzle?  {
        if  currentPuzzleIndex == WordSearchPuzzleGroup.kUndefinedIndex  { return nil }
        return  puzzleArray[currentPuzzleIndex]
    }

    var  nextPuzzle  :WordSearchPuzzle?  {
        selectNextPuzzle()
        return  currentPuzzle
    }

    var  numberOfUnsolvedPuzzles  :Int
    {
        var  countOfSolvedPuzzles  = 0
        puzzleArray.forEach  { if $0.isPuzzleSolved { countOfSolvedPuzzles += 1 } }

        return  (puzzleArray.count - countOfSolvedPuzzles)
    }

    var  isLastPuzzle  :Bool  {
        return  (numberOfUnsolvedPuzzles == 1)
    }


    //
    var  description  :String
    {
        return  """
                \nINSTANCE OF \(Log.filename())--
                    dataFileOrURLString  = \(dataFileOrURLString)
                    iterationMethod      = \(iterationMethod)
                    .
                    puzzleArray.count        = \(puzzleArray.count)
                    numberOfUnsolvedPuzzles  = \(numberOfUnsolvedPuzzles)
                    currentPuzzleIndex       = \(currentPuzzleIndex)
                    isLastPuzzle             = \(isLastPuzzle)
                """
    }



    //----------------------------------------------------------- -o-
    // MARK: - Private properties.

    private var  data  :Data?

    private var  puzzleArray  :[ WordSearchPuzzle ] = []        //INITIAL

    private var  currentPuzzleIndex  :Int = kUndefinedIndex     //INITIAL




    //----------------------------------------------------------- -o-
    // MARK: - Lifecycle.

    /**
     * Initialize from URL String.
     *
     * THROWS from `WordSearchPuzzleGroupError`:
     *   * `.badInputArgument`
     *   * `.downloadFailure`
     *   * `.validationFailure` (via `completeInitialization()`)
     */
    init?(withURLString urlString: String, iterationMethod im:IterationMethod = IterationMethod.random)  throws
    {
        // Parse inputs; initialize class.
        //
        guard let  url = URL.init(string:urlString)  
        else {
            let  errorMessage  = "urlString DOES NOT RESOLVE to URL.  (\(urlString))"
            try  Log.error(errorMessage, WordSearchPuzzleGroupError.badInputArgument(Log.context() + errorMessage))
            return  nil
        }

        dataFileOrURLString             = urlString
        settings.puzzleIterationMethod  = im


        // Download data file.
        //
        let  semaphore            = DispatchSemaphore.init(value:0)
        var  downloadError        = ""
        var  errorMessageSuffix   = "  (\(dataFileOrURLString))"

        let  downloadTask  = URLSession.shared.downloadTask(with: url)
            {
                [weak self]
                (dtURL:URL?, _:URLResponse?, dtError:Error?) in

                defer  { semaphore.signal() }

                //
                guard let  url = dtURL  else {
                    downloadError = "{URLSession()}  " + dtError!.localizedDescription + errorMessageSuffix
                    return
                }

                guard let  strongSelf = self  else {
                    downloadError = "CANNOT ACQUIRE strongSelf." + errorMessageSuffix
                    return
                }

                //
                guard  semaphore.signalReturnCount() <= 0  else { return }

                do {
                    try  strongSelf.data = Data(contentsOf:url, options:.uncached)
                } catch {
                    downloadError = "{Data()}  " + error.localizedDescription + errorMessageSuffix
                }
            }

        downloadTask.resume()


        //
        semaphore.wait(for:WordSearchPuzzleGroup.kDownloadWaitMaxInSeconds)

        guard  downloadError.isEmpty
        else {
            try  Log.error(downloadError, WordSearchPuzzleGroupError.downloadFailure(Log.context() + downloadError))
            return  nil
        }

        guard  semaphore.signalReturnCount() <= 0
        else {
            let  errorMessage  = "Download TIMEOUT EXPIRED." + errorMessageSuffix
            try  Log.error(errorMessage, WordSearchPuzzleGroupError.downloadFailure(Log.context() + errorMessage))
            return  nil
        }


        // Validate input file.
        //
        guard try  completeInitialization()  
        else {
            return nil
        }
    }


    /**
     * Initialize from local resource file.
     *
     * THROWS from `WordSearchPuzzleGroupError`:
     *   * `.badInputArgument`
     *   * `.dataFileLoadFailure`
     *   * `.validationFailure` (via `completeInitialization()`)
     */
    init?(withFile fileName: String, iterationMethod im:IterationMethod = IterationMethod.random)  throws
    {
        let  errorMessageSuffix  = "  (\(fileName))"

        guard let  fileURL = Bundle.main.url(forResource:fileName, withExtension:nil)  
        else {
            let  errorMessage  = "CANNOT FIND file." + errorMessageSuffix
            try  Log.error(errorMessage, WordSearchPuzzleGroupError.badInputArgument(Log.context() + errorMessage))
            return  nil
        }

        dataFileOrURLString             = fileName
        settings.puzzleIterationMethod  = im


        // Locate data file.
        //
        do {
            try  data = Data(contentsOf:fileURL, options:.uncached)

        } catch {
            let  errorMessage  = "{Data()}  " + error.localizedDescription + errorMessageSuffix
            try  Log.error(errorMessage, WordSearchPuzzleGroupError.dataFileLoadFailure(Log.context() + errorMessage))
            return  nil
        }


        // Validate input file.
        //
        guard try  completeInitialization()  
        else {
            return nil
        }
     }


    /**
     * Complete initializtion.
     *
     * Validate data file.
     * Finalize puzzle settings.
     */
    private func  completeInitialization()  throws -> Bool
    {
        do {
            try  self.validatePuzzleData(self.data)

        } catch {
            throw  error
        }


        // Select first puzzle.
        //
        restartIteration(iterationMethod:iterationMethod)


        //
        Log.info(validationProcessingStats.description)
        Log.info(description)

        return  true
    }


    /**
     * Initialize from URL String or local resource file.
     *
     * - Parameters:
     *    + withFileOrURLString **:String**       -- Name of file in local resources or URL string.
     *    + iterationMethod **:IterationMethod**  -- (See `WordSearchPuzzleGroup.IterationMethod`.)
     *
     * UNUSED.
     */
    convenience
    init?(withFileOrURLString fileOrURLString: String, iterationMethod: IterationMethod)  throws
    {
        if  fileOrURLString.hasPrefix("http")  {
            try  self.init(withURLString:fileOrURLString, iterationMethod:iterationMethod)
        } else {
            try  self.init(withFile:fileOrURLString, iterationMethod:iterationMethod)
        }
    }


    deinit
    {
        puzzleArray = []
    }



    //----------------------------------------------------------- -o-
    // MARK: - Private methods (and support).

    /// Also used by unit tests.
    var  validationProcessingStats  = ValidationProcessingStats()

    /**
     *  Process acquired input file.
     *
     *  Check input file is valid.  
     *  Parse individual lines into WordSearchPuzzle objects.
     *  Check there is at least one WordSearchPuzzle object.
     *
     *  On error, THROWS `WordSearchPuzzleGroupError.validationFailure`.
     */

    private func  validatePuzzleData(_ dataOptional: Data?)  throws
    {
        var  dataAcquisitionError  = ""
        var  processingError          = ""

        var  errorMessageSuffix  = "  (\(dataFileOrURLString))"

        var  dataAsString  :String?


        // Check validity of input object.
        //
        if  dataOptional == nil  {
            dataAcquisitionError = "input is nil."

        } else if  dataOptional!.isEmpty  {
            dataAcquisitionError = "input contains NO DATA."

        } else {
            dataAsString = String.init(data:dataOptional!, encoding:String.Encoding.ascii)

            if  dataAsString == nil  {
                dataAcquisitionError = "FAILED TO DECODE Data object."
            }
        }

        guard  dataAcquisitionError.isEmpty  else {
            dataAcquisitionError += errorMessageSuffix
            validationProcessingStats.errorMessage = Log.context() + dataAcquisitionError

            try  Log.error( dataAcquisitionError,
                            WordSearchPuzzleGroupError.validationFailure(validationProcessingStats))
            return
        }


        // Parse input per JSON schema.
        //
        let  arrayOfLines  = dataAsString!.components(separatedBy:"\n")

        for line in arrayOfLines
        {
            var  jsonDictionary  :[String:Any]

            processingError = ""

            defer  {
                if  !processingError.isEmpty  {
                    validationProcessingStats.jsonProcessingFailure += 1
                    try!  Log.error("(line #\(validationProcessingStats.lineCount)) " + processingError)
                }
            }


            //
            validationProcessingStats.lineCount += 1

            guard  line.count > 0  else {
                validationProcessingStats.emptyLines += 1
                processingError = "Line is EMPTY."
                continue
            }


            //
            do {
                jsonDictionary = try JSONSerialization.jsonObject(with:line.data(using:String.Encoding.utf8)!, options:[]) as! [String:Any]

            } catch {
                processingError = error.localizedDescription
                continue
            }


            //
            do {
                let  wspOptional  = try WordSearchPuzzle(withJSON:jsonDictionary)

                guard let  wsp = wspOptional  else {
                    processingError = "WordSearchPuzzle() returned nil."
                    continue
                }

                puzzleArray.append(wsp)
                validationProcessingStats.jsonProcessingSuccess += 1

            } catch  WordSearchPuzzleError.inputIsCorrupt(let message)  {
                processingError = ".inputIsCorrupt: " + message

            } catch {
                processingError = "UNKNOWN ERROR."
            }

            if  !processingError.isEmpty  {
                processingError += "  SKIPPING data for this WordSearchPuzzle..."
                continue
            }

        }  //END for-in line


        // Assess results of parsing WordSearchTranslateGroup file.
        //
        guard  puzzleArray.count > 0  else {
            dataAcquisitionError = "CANNOT FIND ONE VALID WordSearchPuzzle in input file." + errorMessageSuffix
            validationProcessingStats.errorMessage = Log.context() + dataAcquisitionError

            try  Log.error( dataAcquisitionError,
                            WordSearchPuzzleGroupError.validationFailure(validationProcessingStats))
            return
        }
    }


    /**
     *  Select next puzzle.
     *  Adapt to type of iteration at each selection event.
     */
    private func  selectNextPuzzle()
    {
        defer  {
            Log.info("currentPuzzleIndex=\(currentPuzzleIndex)")
        }


        //
        if  numberOfUnsolvedPuzzles <= 0  {
            currentPuzzleIndex = WordSearchPuzzleGroup.kUndefinedIndex
            return
        }


        //
        if  iterationMethod == .inOrder  {
            if  currentPuzzleIndex == WordSearchPuzzleGroup.kUndefinedIndex  { currentPuzzleIndex = 0 }
        } else {
            currentPuzzleIndex = Int.random(in: 0..<puzzleArray.count)
        }

        while  puzzleArray[currentPuzzleIndex].isPuzzleSolved  {
            currentPuzzleIndex += 1
            currentPuzzleIndex %= puzzleArray.count
        }
    }


    func  restartIteration(iterationMethod im: IterationMethod)
    {
        settings.puzzleIterationMethod = im
        puzzleArray.forEach  { $0.resetPuzzleToUnsolved() }

        //
        currentPuzzleIndex = WordSearchPuzzleGroup.kUndefinedIndex
        selectNextPuzzle()
    }

}
