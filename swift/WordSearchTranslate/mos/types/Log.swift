//
// Log.swift
//
//
// DEPENDENCIES--
//   MapEnumIntsToStrings
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
*  Define and order log levels for class `Log`.
*/

enum  LogLevel : String
{
    case  mark, msg, debug, info, warning, error, fatal, disabled

    var  numericValue  :Int
    {
        switch  self  {
        case  .mark:      return LogLevelInt.mark.rawValue
        case  .msg:       return LogLevelInt.msg.rawValue
        case  .debug:     return LogLevelInt.debug.rawValue
        case  .info:      return LogLevelInt.info.rawValue
        case  .warning:   return LogLevelInt.warning.rawValue
        case  .error:     return LogLevelInt.error.rawValue
        case  .fatal:     return LogLevelInt.fatal.rawValue
        case  .disabled:  return LogLevelInt.disabled.rawValue
        }
    }

    //
    private
    enum  LogLevelInt  :Int  {
        case  mark, msg, debug, info, warning, error, fatal, disabled
    }
}




//------------------------------------------------- -o--
// MARK: -

/**
 *  Simple means to post arbitrary text at multiple log levels
 *  automatically labeled with logging context.
 *
 *  Singleton class supports global options including:
 *    * Default log level;
 *    * Relevance of logging to release build lifecycle;
 *    * Whether to use NSLog (providing date and targe prefix information).
 *
 *  Ordered `LogLevel`s span from `LogLevel.debug` through `.fatal`.
 *  `LogLevel.mark` and `.msg` are handled separately.
 *  Use `LogLevel.disabled` to prevent all log messages from posting or taking other actions.
 *
 *  Messages from `Log.error()` may optionaly throw an error and therefore must be preceded by (a form of) `try`.
 *
 *  Messages from `Log.fatal()` cause the program to halt.  (See also class property `fatalHaltsInReleaseBuild`.)
 *
 *
 *  # CLASS PROPERTIES
 *
 *  * `fatalHaltsInReleaseBuild` **:Bool**  -- Disallow release build to ignore `.fatal` messages.  (DEFAULT: `true`.)
 *  * `postViaNSLog` **:Bool**              -- Post with `NSLog()` (versus `print()`).  (DEFAULT: `true`.)
 *  * `postInReleaseBuild` **:Bool**        -- Log in RELEASE builds in addition to DEBUG builds.  (DEFAULT: `true`.)
 *  * `ignoreLogMark` **:Bool**             -- Whether to ignore `.mark` messages.  (DEFAULT: `false`.)
 *  * `ignoreLogMsg` **:Bool**              -- Whether to ignore `.msg` messages.  (DEFAULT: `false`.)
 *  * `minimumLogLevel` **:LogLevel**       -- Set threshold for which log messages are posted.  (DEFAULT: `.debug`.)
 *
 *
 *  # LOGGING FORMATS
 *
 *      1.
 *        LOGLEVEL  FILE_BASENAME :: FUNCTION,LINE  [THREADINFO] -- MESSAGE
 *
 *        Where:
 *          * "-- MESSAGE" presented if a message is given;
 *          * "[THREADINFO]" presented for any thread other than main thread.
 *
 *      2.
 *        Use Log.msg(:) for a simple post without other qualifiers.  Always preceded by "--".
 */

class  Log
{
    //------------------------------------------------- -o-
    // MARK: Properties (and DEFAULTS).

    static var  fatalHaltsInReleaseBuild  = true

    static var  postViaNSLog              = true
    static var  postInReleaseBuild        = true

    static var  ignoreLogMark             = false
    static var  ignoreLogMsg              = false

    static var  minimumLogLevel           = LogLevel.debug
                  {
                    didSet {
                      switch  minimumLogLevel.numericValue
                      {
                      case  LogLevel.info.numericValue...LogLevel.disabled.numericValue:  /*EMPTY*/  break
                      default:
                        try!  error("minimumLogLevel MUST be within range [.debug,.disabled].  (\(minimumLogLevel))")
                        minimumLogLevel = oldValue
                      }
                    }
                  }

    static var  version  = 0.1  //RELEASED



    //------------------------------------------------- -o-
    // MARK: - Methods.

    static func  mark(  _ message     :String = "",
                        file          :String = #file,
                        function      :String = #function,
                        line          :Int = #line,
                        dsohandle     :UnsafeRawPointer = #dsohandle
                    )
    {
        let _ =  logit(LogLevel.mark, message, file, function, line, dsohandle)
    }

    static func  msg(  _ message     :String = "",
                       file          :String = #file,
                       function      :String = #function,
                       line          :Int = #line,
                       dsohandle     :UnsafeRawPointer = #dsohandle
                    )
    {
        let _ =  logit(LogLevel.msg, message, file, function, line, dsohandle)
    }

    static func  debug(  _ message     :String = "",
                         file          :String = #file,
                         function      :String = #function,
                         line          :Int = #line,
                         dsohandle     :UnsafeRawPointer = #dsohandle
                    )
    {
        let _ =  logit(LogLevel.debug, message, file, function, line, dsohandle)
    }

    static func  info(  _ message     :String = "",
                        file          :String = #file,
                        function      :String = #function,
                        line          :Int = #line,
                        dsohandle     :UnsafeRawPointer = #dsohandle
        )
    {
        let _ =  logit(LogLevel.info, message, file, function, line, dsohandle)
    }

    static func  warning(  _ message     :String = "",
                           file          :String = #file,
                           function      :String = #function,
                           line          :Int = #line,
                           dsohandle     :UnsafeRawPointer = #dsohandle
                )
    {
        let _ =  logit(LogLevel.warning, message, file, function, line, dsohandle)
    }

    /**
     * **NOTE:**  All instances of `Log.error()` may optionally throw an error.
     * Hence, all instances of `Log.error()` must be preceded by (a form of) `try`.
     */
    static func  error(  _ message     :String = "",
                         _ errorType   :Error? = nil,
                         file          :String = #file,
                         function      :String = #function,
                         line          :Int = #line,
                         dsohandle     :UnsafeRawPointer = #dsohandle
                    ) throws
    {
        if  !logit(LogLevel.error, message, file, function, line, dsohandle)  { return }

        guard let  error = errorType  else { return }
        throw  error
    }

    /**
     * **NOTE:**  All instances of `Log.fatal()` cause the program to halt.
     * (See also class property `fatalHaltsInReleaseBuild`.)
     */
    static func  fatal(  _ message     :String = "",
                         file          :String = #file,
                         function      :String = #function,
                         line          :Int = #line,
                         dsohandle     :UnsafeRawPointer = #dsohandle
                    )
    {
        if  !logit(LogLevel.fatal, message, file, function, line, dsohandle)  { return }

        if  fatalHaltsInReleaseBuild  {
            fatalError(message)
        } else {
            assertionFailure(message)
        }
    }



    //------------------------------------------------- -o-
    // MARK: - Public helper methods.

    /**
     * Capture code filename.
     *
     * - Parameters:
     *    + file **:String** -- (DEFAULT (in caller): `#file`)
     *
     * ASSUME `file` is an absolute pathname to a file with a dot suffix.
     */
    static func  filename(_ filePath: String = #file)  -> String
    {
        return  filePath.components(separatedBy: "/").last!.components(separatedBy: ".").first!
    }


    /**
     * Capture code context and runtime thread info.
     *
     * - Parameters:
     *    + addBraces **:Bool**              -- When true, add braces indicate indirection.  (DEFAULT: false)
     *    + file **:String**                 -- (DEFAULT (in caller): `#file`)
     *    + function **:String**             -- (DEFAULT (in caller): `#function`)
     *    + line **:String**                 -- (DEFAULT (in caller): `#line`)
     *    + dsohandle **:UnsafeRawPointer**  -- Experimental.  Unused.  (DEFAULT (in caller): `#dsohandle`)
     */
    static func  context( _ addBraces  :Bool = true,
                          file         :String = #file,
                          function     :String = #function,
                          line         :Int = #line,
                          dsohandle    :UnsafeRawPointer = #dsohandle
                    ) -> String
    {
        let  contextBase  = "\(filename(file)) :: \(function),\(line)"

        //
        var  threadDetails  = ""

        if  !Thread.isMainThread  {
            let  currentThread  = Thread.current

            threadDetails = " ["

            threadDetails += "\(currentThread.qualityOfService.pretty()), \(currentThread.threadPriority)"

            if let  threadName = currentThread.name, threadName.count > 0  {
                threadDetails += ", \"\(currentThread.name!)\""
            }

            threadDetails += "]"
        }

        //
        var  contextAdditions  = contextBase + threadDetails

        if  addBraces  { contextAdditions = "{" + contextAdditions + "} " }

        return  contextAdditions
    }



    //------------------------------------------------- -o-
    // MARK: - Private helper methods.

    /**
     *  Configure log level for app context.
     *
     *  (See class header documentation for more details.)
     *
     *  NB -- All public log methods are executed, including any additional code invoked
     *        via string interpolation, even if the the LogLevel prevents their output from
     *        being posted or other actions from being taken.
     *
     * - Parameters:
     *    + logLevel  **:LogLevel**  -- Lowest level for which Log methods will post their message or take other actions.
     */
    private
    static func  allowLoggingPerConfiguration(logLevel: LogLevel)  -> Bool
    {
    #if DEBUG
        /*EMPTY*/
    #else
        if  !postInReleaseBuild  { return false }
    #endif

        //
        switch  logLevel  {
        case  .mark:  if  ignoreLogMark  { return false }
        case  .msg:   if  ignoreLogMsg  { return false }

        default:
          if  logLevel.numericValue < minimumLogLevel.numericValue  { return false }
        }

        return  true
    }


    /**
     * Log the message with appropriate context, per configuration.
     *
     * - Parameters:
     *    + logLevel **:LogLevel**           -- `LogLevel` of `Log` method.
     *    + message **:String**              -- Defined by user in caller.
     *    + file **:String**                 -- (DEFAULT (in caller): `#file`)
     *    + function **:String**             -- (DEFAULT (in caller): `#function`)
     *    + line **:String**                 -- (DEFAULT (in caller): `#line`)
     *    + dsohandle **:UnsafeRawPointer**  -- Experimental.  Unused.  (DEFAULT (in caller): `#dsohandle`)
     *
     * - Returns:
     *    `false` if `allowLoggingPerConfiguration(:)` prevents this Log message from being posted;
     *    `true` otherwise.
     */
    private
    static func  logit(  _ logLevel     :LogLevel,
                         _ message      :String,
                         _ file         :String,
                         _ function     :String,
                         _ line         :Int,
                         _ dsohandle    :UnsafeRawPointer
                     ) -> Bool
    {
        if  !allowLoggingPerConfiguration(logLevel:logLevel)  { return false }


        //
        var  logOutput  = ""

        if  logLevel != LogLevel.msg  {
            logOutput = " \(logLevel.rawValue.uppercased())  " + context( false,
                                                                          file:      file,
                                                                          function:  function,
                                                                          line:      line,
                                                                          dsohandle: dsohandle
                                                                    )
        }

        if  (message.count > 0) || (logLevel == LogLevel.msg)  {
            logOutput += " -- \(message)"
        }


        //
        if  postViaNSLog  {
            NSLog(logOutput)
        } else {
            print(logOutput)
        }

        return  true
    }

}

