//
// Array+MOS.swift
//
//
//---------------------------------------------------------------------
//     Copyright (C) 2019 David Reeder.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

import Foundation




//------------------------------------------ -o--
// MARK: -

extension  Array
{
    // MARK: Lifecycle.

    init(repeatingUnique uniqueValue: @autoclosure () -> Element, count: Int)
    {
        self = (0..<count).map  { _ in uniqueValue() }
    }

}

