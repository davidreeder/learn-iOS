//
// SetCard_universal.h
//
// Set Match game categories for shapes, colors and shades.
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------



//---------------------------------------------------- -o-
typedef enum { 
  SCShapeOne=0, SCShapeTwo, SCShapeThree, SCShapeMax }       SCShape;

typedef enum { 
  SCColorOne=0, SCColorTwo, SCColorThree, SCColorMax }       SCColor;

typedef enum { 
  SCShadeFull=0, SCShadePartial, SCShadeClear, SCShadeMax }  SCShade;

#define SETCARD_COUNT_MAX  3

