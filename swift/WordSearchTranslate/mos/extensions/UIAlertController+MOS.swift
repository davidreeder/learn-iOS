//
// UIAlertController+MOS.swift
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

import  Foundation
import  UIKit




//------------------------------------------ -o--
// MARK: -

extension  UIAlertController
{
    //------------------------------------------------- -o-
    // MARK: Class methods.

    static func  postAlertFatalError( _ message          :String,
                                      parent vc          :UIViewController,
                                      allowTransparency  :Bool = false,
                                      file               :String = #file,
                                      function           :String = #function,
                                      line               :Int = #line,
                                      dsohandle          :UnsafeRawPointer = #dsohandle
        )
    {
        let  alertTitle   = "FATAL ERROR"
        let  buttonTitle  = "Quit."

        let  annotatedMessage  =  """
        \(message)

        \(Log.context(false, file:file, function:function, line:line, dsohandle:dsohandle))
        """

        func  logFatalError(_: UIAlertAction)  { Log.fatal(message, file:file, function:function, line:line, dsohandle:dsohandle) }

        let  quitButton  = UIAlertAction(title:buttonTitle, style:.destructive, handler:logFatalError(_:))

        //
        let  alert  = UIAlertController(title:alertTitle, message:annotatedMessage, preferredStyle:.alert)
        alert.addAction(quitButton)

        if  !allowTransparency  {
            let  alertSubview  = (alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
            alertSubview.backgroundColor = UIColor.white
        }

        vc.present(alert, animated:false)
    }


    static func  postAlertOneButton( title              :String,
                                     message            :String,
                                     buttonTitle        :String = "OK",
                                     parent vc          :UIViewController,
                                     allowTransparency  :Bool = false
        )                                                               -> UIAlertController
    {
        let  basicButton  = UIAlertAction(title:buttonTitle, style:.default, handler:nil)

        //
        let  alert  = UIAlertController(title:title, message:message, preferredStyle:.alert)
        alert.addAction(basicButton)

        if  !allowTransparency  {
            alert.getAlertSubview().backgroundColor = UIColor.white
        }

        vc.present(alert, animated:false)

        //
        return  alert
    }



    //------------------------------------------------- -o-
    // MARK: - Instance methods.

    func  getAlertSubview()  -> UIView
    {
        return  (self.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
    }

}

