//
// MapEnumIntsToStrings.swift
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

extension  QualityOfService
{
    public func  pretty()  -> String
    {
        switch  self
        {
        case  .userInteractive:  return  QualityOfServiceString.userInteractive.rawValue
        case  .userInitiated:    return  QualityOfServiceString.userInitiated.rawValue
        case  .utility:          return  QualityOfServiceString.utility.rawValue
        case  .background:       return  QualityOfServiceString.background.rawValue
        case  .`default`:        return  QualityOfServiceString.`default`.rawValue

        default:                 return  QualityOfServiceString.UNKNOWN.rawValue
        }
    }

    private enum  QualityOfServiceString : String  {
        case  userInteractive, userInitiated, utility, background, `default`, UNKNOWN
    }

}




//------------------------------------------ -o--
// MARK: -

extension  UIDeviceOrientation
{
    public func  pretty()  -> String
    {
        switch  self
        {
        case  .unknown:              return  UIDeviceOrientationString.unknown.rawValue
        case  .portrait:             return  UIDeviceOrientationString.portrait.rawValue
        case  .portraitUpsideDown:   return  UIDeviceOrientationString.portraitUpsideDown.rawValue
        case  .landscapeLeft:        return  UIDeviceOrientationString.landscapeLeft.rawValue
        case  .landscapeRight:       return  UIDeviceOrientationString.landscapeRight.rawValue
        case  .faceUp:               return  UIDeviceOrientationString.faceUp.rawValue
        case  .faceDown:             return  UIDeviceOrientationString.faceDown.rawValue

        default:                     return  UIDeviceOrientationString.UNKNOWN.rawValue
        }
    }

    private enum  UIDeviceOrientationString : String  {
        case  unknown, portrait, portraitUpsideDown, landscapeLeft, landscapeRight, faceUp, faceDown, UNKNOWN
    }
}



//------------------------------------------ -o--
// MARK: -

extension  UIGestureRecognizer.State
{
    public func  pretty()  -> String
    {
        switch  self
        {
        case  .possible:        return  StateString.possible.rawValue
        case  .began:           return  StateString.began.rawValue
        case  .changed:         return  StateString.changed.rawValue
        case  .ended:           return  StateString.ended.rawValue
        case  .cancelled:       return  StateString.cancelled.rawValue
        case  .failed:          return  StateString.failed.rawValue

        default:                return  StateString.UNKNOWN.rawValue
        }
    }

    private enum  StateString : String  {
        case  possible, began, changed, ended, cancelled, failed, UNKNOWN
    }
}



//------------------------------------------ -o--
// MARK: -

extension  UISplitViewController.DisplayMode
{
    public func  pretty()  -> String
    {
        switch  self
        {
        case  .automatic:       return DisplayModeString.automatic.rawValue
        case  .primaryHidden:   return DisplayModeString.primaryHidden.rawValue
        case  .allVisible:      return DisplayModeString.allVisible.rawValue
        case  .primaryOverlay:  return DisplayModeString.primaryOverlay.rawValue

        default:                return DisplayModeString.UNKNOWN.rawValue
        }
    }

    private enum  DisplayModeString  :String  {
        case automatic, primaryHidden, allVisible, primaryOverlay, UNKNOWN
    }
}

