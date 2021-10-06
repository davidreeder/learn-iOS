//
// UIDevice+MOS.swift
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

import  Foundation
import  UIKit




//------------------------------------------ -o--
// MARK: -

extension  UIDevice
{
    //
    static var  isIPad  :Bool  { return  UIDevice.current.model.hasPrefix("iPad") }

    static var  orientationString  :String  { return UIDevice.current.orientation.pretty() }


    //
    static func  pretty()  -> String
    {
        let  currentDevice  = UIDevice.current
        return  "\(currentDevice.name), \(currentDevice.systemName) \(currentDevice.systemVersion)"
    }

}

