//
// DispatchSemaphore+MOS.swift
//
//
// DEPENDENCIES--
//   Log
//
//
//---------------------------------------------------------------------
//     Copyright (C) 2019 David Reeder.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

import Foundation




//----------------------------------------------- -o--
// MARK: -

extension  DispatchSemaphore
{
    // MARK: Type definitions.

    /// Supporting type for `wait(for:)`.
    enum  ReturnCountAction  : String  {
        case  value, increment, clear
    }



    //----------------------------------------------- -o-
    // MARK: - Instance methods.

    /**
     *  Maintain a counter specific to this instance of DispatchSemaphore.
     *
     *  By default (`action` = `.value`), no argument is necessary, the value of the counter is returned.
     *  Set `action` to `.increment` or `.clear` to increment the counter by one or to reset it to zero (0).
     */
    func  signalReturnCount(action: ReturnCountAction = .value)  -> Int
    {
        struct  Static  { static var  sumOfSignalReturnValues  = 0 }

        //
        switch  action
        {
        case  .value:
            let _ =  "EMPTY"

        case  .increment:
            Static.sumOfSignalReturnValues += 1

        case  .clear:
            Static.sumOfSignalReturnValues = 0
        }

        //
        return  Static.sumOfSignalReturnValues
    }


    /**
     *  Increment a counter specific to this DispatchSemaphore instance
     *  if signal() indicates that another thread has been woken.
     */
    func  signalAndCount()  -> Int
    {
        if  self.signal() > 0  {
            let _ =  self.signalReturnCount(action:.increment)
            return  1
        }

        return  0
    }


    /**
     *  Wait up to N seconds to receive a signal() from without,
     *  otherwise break the wait by generating a signal() from within.
     *
     *  - Parameters:
     *     + seconds  **:Double**             -- Duration to wait for a signal() from without.
     *     + clearReturnCount  **:Bool:       -- Optionally clear the internal signal counter before waiting.
     *     + queueLabel  **:String**          -- Optionally set the queue label.  By default it is set using `Log.context()`.
     *     + file **:String**                 -- (DEFAULT (in caller): `#file`)
     *     + function **:String**             -- (DEFAULT (in caller): `#function`)
     *     + line **:String**                 -- (DEFAULT (in caller): `#line`)
     *     + dsohandle **:UnsafeRawPointer**  -- Experimental.  Unused.  (DEFAULT (in caller): `#dsohandle`)
     */
    func  wait( for seconds       :Double,
                clearReturnCount  :Bool = false,
                queueLabel        :String = "",
                file              :String = #file,
                function          :String = #function,
                line              :Int = #line,
                dsohandle         :UnsafeRawPointer = #dsohandle
        )
    {
        guard  seconds >= 0  else {
            Log.fatal("seconds MUST BE GREATER THAN OR EQUAL to zero.  (\(seconds))")
            return
        }


        //
        var  label  = queueLabel
        if  label.isEmpty  { label = Log.context(true, file:file, function:function, line:line, dsohandle:dsohandle) }

        let  delayTask  = DispatchQueue(label:label, qos:.background)

        if  clearReturnCount  { let _ = signalReturnCount(action:.clear) }

        delayTask.async
            {
                Thread.sleep(forTimeInterval:seconds)
                let _ =  self.signalAndCount()
            }


        //
        self.wait()
    }

}

