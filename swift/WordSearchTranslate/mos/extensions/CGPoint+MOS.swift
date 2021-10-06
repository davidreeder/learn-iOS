//
// CGPoint+MOS.swift
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

extension  CGPoint
{
    func  distance(to cgPoint: CGPoint)  -> CGFloat
    {
        return  sqrt( pow(self.x - cgPoint.x, 2) + pow(self.y - cgPoint.y, 2) )  as CGFloat
    }
}

