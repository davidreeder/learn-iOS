//
// ProcessInfo+MOS.swift
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

extension  ProcessInfo
{
    static func  contains(argument variable: String)  -> Bool
    {
        return  ProcessInfo().arguments.contains(variable)
    }

}

