//
// UISplitViewController+MOS.swift
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

extension  UISplitViewController
{
    var  masterAsNavigationController  :UINavigationController  {
        return  viewControllers.first as! UINavigationController
    }


    var  detailIsNavigationController  :Bool  {
        return  viewControllers.last is UINavigationController
    }

    var  detailAsNavigationController  :UINavigationController  {
        return  viewControllers.last as! UINavigationController
    }

}

