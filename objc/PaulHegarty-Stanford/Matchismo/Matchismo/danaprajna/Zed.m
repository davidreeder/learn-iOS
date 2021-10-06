//
// Zed.m
//
// Kitchen sink.  Put any routines here that do not naturally collect
// into their own class.
//
// CLASS METHODS--
//   colorWith255Red:green:blue:alpha:
//   dateFormatFullShort:
//   scaleValue:fromX1:y1:intoX2:y2:invertedMap:rounded:
//   shuffleArray:
//   sortTuples:atIndex:withBlock:
//   
//   udGet:
//   udSet:dictionary:
//
//   udObjectGet:dictionaryKey:
//   udArrayGet:dictionaryKey:
//   udDataGet:dictionaryKey:
//   udDateGet:dictionaryKey:
//   udDictionaryGet:dictionaryKey:
//   udStringGet:dictionaryKey:
//   udIntegerGet:dictionaryKey:
//   udUIntegerGet:dictionaryKey:
//   udFloatGet:dictionaryKey:
//   udDoubleGet:dictionaryKey:
// 
//   udObjectSet:dictionaryKey:object:
//   udObjectRemove:dictionaryKey:
//   udRemove:
//
//   cgAddPoint:toPoint:
//   cgScalePoint:withScalar:
//   cgScalePoint:withFractionalPoint:
//   cgAddPoint:toPoint:thenScale:
//   cgAddPoint:toPoint:scaleWithFractionalPoint:
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "Zed.h"



//---------------------------------------------------- -o--
@implementation Zed

//
// Miscellaneous methods.
//

//------------------- -o-
+ (UIColor *) colorWith255Red: (NSUInteger)red
			green: (NSUInteger)green
			 blue: (NSUInteger)blue
			alpha: (float)alpha
{
  return [UIColor colorWithRed: red / 255.0 
                         green: green / 255.0
			  blue: blue / 255.0
			 alpha: alpha ];
}



//------------------- -o-
// dateFormatFullShort: 
//
// XXX  Locale is hardwired to en_US.
//
+ (NSString *) dateFormatFullShort: (NSDate *)date
{
  static NSDateFormatter  *dateFormatter = nil;
  static NSLocale         *usLocale = nil;

  //
  if (!dateFormatter) {
    dateFormatter = [[NSDateFormatter alloc] init];
  }

  if (!usLocale) {
    usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
  }

  //
  [dateFormatter setDateStyle:  NSDateFormatterShortStyle];
  [dateFormatter setTimeStyle:  NSDateFormatterShortStyle];
  [dateFormatter setLocale:     usLocale];

  return [dateFormatter stringFromDate:date];

} // dateFormatFullShort: 



//------------------- -o-
// scaleValue:fromX1:y1:intoX2:y2:invertedMap:rounded:
//
// TBD  exponential mapping, optionally biased towards beginning or end
//      of range2.
//
+ (float)scaleValue: (float)value 
             fromX1: (float)x1  y1: (float)y1 
             intoX2: (float)x2  y2: (float)y2  
        invertedMap: (BOOL)invertedMap
            rounded: (BOOL)rounded
{
  // Normalize inputs.
  //
  float tmp;

  if (x1 > y1)  { tmp = x1; x1 = y1; y1 = tmp; }
  if (x2 > y2)  { tmp = x2; x2 = y2; y2 = tmp; }

  if (value < x1)  { value = x1; }
  if (value > y1)  { value = y1; }


  // Do something.
  //
  float range1      = y1 - x1,
        range2      = y2 - x2,
        percentage  = fabsf( (x1-value)/ range1 );

  float rval = invertedMap ? y2-(range2*percentage) : x2+(range2*percentage);

  //[Dump objs:@[ @"scaleValue", DP_DUMPLON(percentage), @(rval)]];


  return rounded ? roundf(rval) : rval;

} // scaleValue:fromX1:y1:intoX2:y2:invertedMap:rounded:



//------------------- -o-
// shuffleArray:
//
// Shuffle elements of input array, write new order into shuffledArray.
// Do this by walking through the array, swapping each element with a
// random element in the array.
//
// Time efficiency: O(N)
// Space efficiency: N + C
//
// NB  Converts input NSArray to NSMutableArray, as necessary.
//
// RETURN  inputArray with the elements randomly reordered.
//
+ (NSMutableArray *) shuffleArray: (NSArray *)inputArray
{
  NSMutableArray *inputMutableArray;

  if ([inputArray isKindOfClass:[NSMutableArray class]]) {
    inputMutableArray = (NSMutableArray *) inputArray;
  } else {
    inputMutableArray = [inputArray mutableCopy];
  }


  // Return degenerate cases.
  //
  NSUInteger arraySize = [inputMutableArray count];

  if (arraySize <= 0) {
    return nil;

  } else if (1 == arraySize) {
    return inputMutableArray;
  }


  // Shuffle input array.
  //
  for (int i = 0; i < arraySize; i++) 
  {
    [inputMutableArray exchangeObjectAtIndex: i
                           withObjectAtIndex: arc4random() % arraySize
    ];
  }

  return inputMutableArray;

} // shuffleArray: 



//------------------- -o-
// sortTuples:atIndex:withBlock:
//
// Sort array of arrays using element index of each array as a key.
// Keys are not required to be unique, however, order of elements with
//   identical keys is unstable.
// NSComparator, block, MUST be in the form defined by 
//   DP_BLOCK_CMP*_INDEX0_* macros.
//
// Use this to sort an array of elements when the element class cannot 
//   be supplemented with a comparator.
//
// ASSUME  Array elements are all in the same format.
// ASSUME  index is no larger than smallest common sequence of initial
//           array elements for each element of container array.
//
+ (NSArray *) sortTuples: (NSArray *)    tuples
                 atIndex: (NSUInteger)   index
               withBlock: (NSComparator) block
{
  NSMutableArray  *fauxDict      = [[NSMutableArray alloc] init];
  NSArray         *sortedFauxDict;
  NSMutableArray  *sortedTuples  = [[NSMutableArray alloc] init];


  for (NSArray *tuple in tuples) {
    [fauxDict addObject:@[tuple[index], tuple]];
  }

  sortedFauxDict = [fauxDict sortedArrayUsingComparator:block];

  for (id obj in sortedFauxDict) {
    [sortedTuples addObject:obj[1]];
  }


  return sortedTuples;

} // sortTuples:atIndex:withBlock:




//---------------------------------------------------- -o--
// Shortcuts and wrappers for NSUserDefaults.
//

//------------------- -o-
// udGet:
//
// RETURN:  Mutable form of NSUserDefaults dictionary at dictKey  
//            -OR-  nil.
//
+ (NSMutableDictionary *) udGet:(NSString *)dictKey
{
  if (!dictKey) {
    [Log errorMsg:
      DP_STRWFMT(@"%@ :: udGet: -- dictKey is nil!", [self class])];
    return nil;
  }

  NSString *key = DP_MAKE_UDKEY_STR(dictKey);
  return [[[NSUserDefaults standardUserDefaults] 
            			dictionaryForKey:key] mutableCopy ];
}


//------------------- -o-
// udSet:dictionary:
//
// Write and synchronize NSUserDefaults with dictContent at dictKey.
//
+ (void)      udSet: (NSString *)     dictKey 
         dictionary: (NSDictionary *) dictContent
{
  if (!dictKey) {
    [Log errorMsg:
      DP_STRWFMT(@"%@ :: udSet:... -- dictKey is nil!", [self class])];
    return;
  } else if (!dictContent) {
    [Log errorMsg:
      DP_STRWFMT(@"%@ :: udSet:... -- dictContent is nil!", [self class])];
    return;
  }

  NSString *key = DP_MAKE_UDKEY_STR(dictKey);
  [[NSUserDefaults standardUserDefaults] setObject:dictContent forKey:key];
  [[NSUserDefaults standardUserDefaults] synchronize];
}



//------------------- -o-
// udObjectGet:dictionaryKey:
//
// RETURN: Object at objectKey from NSUserDefaults dictionary at dictKey  
//           -OR-  nil.
//
+ (NSObject *)   udObjectGet: (NSString *) objectKey 
               dictionaryKey: (NSString *) dictKey
{
  if (!objectKey) {
    [Log errorMsg:
      DP_STRWFMT(@"%@ :: udObjectGet:... -- objectKey is nil!", [self class])];
    return nil;
  } else if (!dictKey) {
    [Log errorMsg:
      DP_STRWFMT(@"%@ :: udObjectGet:... -- dictKey is nil!", [self class])];
    return nil;
  }

  return [[Zed udGet:dictKey] objectForKey:objectKey];
}


+ (NSMutableArray *)    udArrayGet: (NSString *) objectKey 
                     dictionaryKey: (NSString *) dictKey
{
  return [(NSArray *) 
    [Zed udObjectGet:objectKey dictionaryKey:dictKey] mutableCopy];
}


+ (NSMutableData *)     udDataGet: (NSString *) objectKey 
                    dictionaryKey: (NSString *) dictKey
{
  return [(NSData *) 
    [Zed udObjectGet:objectKey dictionaryKey:dictKey] mutableCopy];
}


+ (NSDate *)     udDateGet: (NSString *) objectKey 
             dictionaryKey: (NSString *) dictKey
{
  return (NSDate *) [Zed udObjectGet:objectKey dictionaryKey:dictKey];
}


+ (NSMutableDictionary *) udDictionaryGet: (NSString *) objectKey 
                            dictionaryKey: (NSString *) dictKey
{
  return [(NSDictionary *) 
    [Zed udObjectGet:objectKey dictionaryKey:dictKey] mutableCopy];
}


+ (NSMutableString *)   udStringGet: (NSString *) objectKey 
                      dictionaryKey: (NSString *) dictKey
{
  return [(NSString *) 
    [Zed udObjectGet:objectKey dictionaryKey:dictKey] mutableCopy];
}


+ (NSInteger)  udIntegerGet: (NSString *) objectKey 
              dictionaryKey: (NSString *) dictKey
{
  return [(NSNumber *) 
    [Zed udObjectGet:objectKey dictionaryKey:dictKey] integerValue];
}

+ (NSUInteger) udUIntegerGet: (NSString *) objectKey 
               dictionaryKey: (NSString *) dictKey
{
  return [(NSNumber *) 
    [Zed udObjectGet:objectKey dictionaryKey:dictKey] unsignedIntegerValue];
}


+ (float)    udFloatGet: (NSString *) objectKey 
          dictionaryKey: (NSString *) dictKey
{
  return [(NSNumber *) 
    [Zed udObjectGet:objectKey dictionaryKey:dictKey] floatValue];
}

+ (double)   udDoubleGet: (NSString *) objectKey 
             dictionaryKey: (NSString *) dictKey
{
  return [(NSNumber *) 
    [Zed udObjectGet:objectKey dictionaryKey:dictKey] doubleValue];
}




//------------------- -o-
// udObjectSet:dictionaryKey:object:
//
// Write and synchronize object at objectKey in dictKey dictionary 
//   within NSUserDefaults.
// Create dictionary if it does not exist.
//
+ (void)   udObjectSet: (NSString *) objectKey 
         dictionaryKey: (NSString *) dictKey
                object: (NSObject *) objectContent
{
  if (!objectKey) {
    [Log errorMsg:
      DP_STRWFMT(@"%@ :: udObjectSet:... -- objectKey is nil!", [self class])];
    return;
  } else if (!dictKey) {
    [Log errorMsg:
      DP_STRWFMT(@"%@ :: udObjectSet:... -- dictKey is nil!", [self class])];
    return;
  } else if (!objectContent) {
    [Log errorMsg: 
      DP_STRWFMT(@"%@ :: udObjectSet:... -- objectContent is nil!", 
        [self class])];
    return;
  }

  NSMutableDictionary *dict = [Zed udGet:dictKey];

  if (!dict) {
    dict = [[NSMutableDictionary alloc] init];
  }

  [dict setObject:objectContent forKey:objectKey];
  [Zed udSet:dictKey dictionary:dict];
}



//------------------- -o-
// udObjectRemove:dictionaryKey:
//
// Remove objectKey in from dictionary at dictionaryKey.
//
+ (void) udObjectRemove: (NSString *) objectKey 
          dictionaryKey: (NSString *) dictKey
{
  if (!objectKey) {
    [Log errorMsg:
      DP_STRWFMT(@"%@ :: udObjectSet:... -- objectKey is nil!", [self class])];
    return;
  } else if (!dictKey) {
    [Log errorMsg:
      DP_STRWFMT(@"%@ :: udObjectSet:... -- dictKey is nil!", [self class])];
    return;
  }

  NSMutableDictionary *dict = [Zed udGet:dictKey];

  if (dict) {
    [dict removeObjectForKey:objectKey];
  }
}


//------------------- -o-
// udRemove:
//
+ (void) udRemove: (NSString *) dictKey
{
  NSString *key = DP_MAKE_UDKEY_STR(dictKey);

  [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}




//---------------------------------------------------- -o--
// CGPoint arithmetic and scaling.
// 

//------------------- -o-
+ (CGPoint) cgAddPoint: (CGPoint)A  
               toPoint: (CGPoint)B
{
  return CGPointMake(A.x + B.x, A.y + B.y);
}


//------------------- -o-
// cgScalePoint:withFractionalPoint: 
//
// fractionalPoint contains ratios for X and Y axes;
//   does not represent a real point.
//
+ (CGPoint) cgScalePoint: (CGPoint)A  
     withFractionalPoint: (CGPoint)fractionalPoint
{
  return CGPointMake(A.x * fractionalPoint.x, A.y * fractionalPoint.y);
}


//------------------- -o-
+ (CGPoint) cgScalePoint: (CGPoint)A  
              withScalar: (CGFloat)scalar
{
  return [Zed cgScalePoint:A withFractionalPoint:CGPointMake(scalar, scalar)];
}


//------------------- -o-
+ (CGPoint)     cgAddPoint: (CGPoint)A  
                   toPoint: (CGPoint)B 
  scaleWithFractionalPoint: (CGPoint)fractionalPoint
{
  return [Zed      cgScalePoint: [Zed cgAddPoint:A toPoint:B] 
            withFractionalPoint: fractionalPoint];
}


//------------------- -o-
+ (CGPoint) cgAddPoint: (CGPoint)A  
               toPoint: (CGPoint)B 
             thenScale: (CGFloat)scalar
{
  return [Zed cgScalePoint:[Zed cgAddPoint:A toPoint:B] withScalar:scalar];
}


@end // Zed

