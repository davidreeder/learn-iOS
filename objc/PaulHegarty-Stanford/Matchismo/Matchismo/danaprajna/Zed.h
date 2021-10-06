//
// Zed.h
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#define DP_VERSION_ZED  0.3


#import "Danaprajna.h"



//---------------------------------------------------- -o-
@interface Zed : NSObject

  //
  // Miscellaneous methods.
  //

  + (UIColor *) colorWith255Red: (NSUInteger)red
			  green: (NSUInteger)green
			   blue: (NSUInteger)blue
			  alpha: (float)alpha;

  + (NSString *) dateFormatFullShort: (NSDate *)date;

  + (float) scaleValue: (float)value 
                fromX1: (float)x1  y1: (float)y1 
                intoX2: (float)x2  y2: (float)y2
           invertedMap: (BOOL)invertedMap
               rounded: (BOOL)rounded;

  + (NSMutableArray *) shuffleArray: (NSArray *)inputArray;

  + (NSArray *) sortTuples: (NSArray *)    tuples
                   atIndex: (NSUInteger)   index
                 withBlock: (NSComparator) block;


  //
  // Shortcuts and wrappers for NSUserDefaults.
  //

  + (NSMutableDictionary *) udGet:(NSString *)dictKey;

  + (void)      udSet: (NSString *)     dictKey 
           dictionary: (NSDictionary *) dictContent;

  //
  + (NSObject *)   udObjectGet: (NSString *) objectKey 
                 dictionaryKey: (NSString *) dictKey;

  + (NSMutableArray *)    udArrayGet: (NSString *) objectKey 
                       dictionaryKey: (NSString *) dictKey;

  + (NSMutableData *)     udDataGet: (NSString *) objectKey 
                      dictionaryKey: (NSString *) dictKey;

  + (NSDate *)     udDateGet: (NSString *) objectKey 
               dictionaryKey: (NSString *) dictKey;

  + (NSMutableDictionary *) udDictionaryGet: (NSString *) objectKey 
                              dictionaryKey: (NSString *) dictKey;

  + (NSMutableString *)   udStringGet: (NSString *) objectKey 
                        dictionaryKey: (NSString *) dictKey;

  + (NSInteger)  udIntegerGet: (NSString *) objectKey 
                dictionaryKey: (NSString *) dictKey;
  + (NSUInteger) udUIntegerGet: (NSString *) objectKey 
                 dictionaryKey: (NSString *) dictKey;

  + (float)    udFloatGet: (NSString *) objectKey 
            dictionaryKey: (NSString *) dictKey;
  + (double)   udDoubleGet: (NSString *) objectKey 
             dictionaryKey: (NSString *) dictKey;

  //
  + (void)   udObjectSet: (NSString *) objectKey 
           dictionaryKey: (NSString *) dictKey
                  object: (NSObject *) objectContent;

  //
  + (void) udObjectRemove: (NSString *) objectKey 
            dictionaryKey: (NSString *) dictKey;

  + (void) udRemove: (NSString *) dictKey;



  //
  // CGPoint arithmetic and scaling.
  //

  + (CGPoint) cgAddPoint: (CGPoint)A  
                 toPoint: (CGPoint)B;

  + (CGPoint) cgScalePoint: (CGPoint)A  
                withScalar: (CGFloat)scalar;

  + (CGPoint) cgScalePoint: (CGPoint)A  
       withFractionalPoint: (CGPoint)fractionalPoint;

  + (CGPoint) cgAddPoint: (CGPoint)A  
                 toPoint: (CGPoint)B 
               thenScale: (CGFloat)scalar;

  + (CGPoint)     cgAddPoint: (CGPoint)A  
                     toPoint: (CGPoint)B 
    scaleWithFractionalPoint: (CGPoint)fractionalPoint;

@end // Zed




//------------------------------------------------ -o-
// Common blocks for sorting NSString, NSNumber, NSDate
//

#define DP_BLOCK_CMPSTR_LT  \
            ^(NSString *str1, NSString *str2) { return [str1 compare:str2]; }
#define DP_BLOCK_CMPSTR_GT  \
            ^(NSString *str1, NSString *str2) { return [str2 compare:str1]; }
#define DP_BLOCK_CMPSTR  DP_BLOCK_CMPSTR_LT

#define DP_BLOCK_CMPSTR_INDEX0_LT                                        \
            ^(NSArray *arr1, NSArray *arr2) {                            \
              return [(NSString *)arr1[0] compare:(NSString *)arr2[0]];  \
            }
#define DP_BLOCK_CMPSTR_INDEX0_GT                                        \
            ^(NSArray *arr1, NSArray *arr2) {                            \
              return [(NSString *)arr2[0] compare:(NSString *)arr1[0]];  \
            }
#define DP_BLOCK_CMPSTR_INDEX0  DP_BLOCK_CMPSTR_INDEX0_LT



#define DP_BLOCK_CMPNUM_LT  \
            ^(NSNumber *num1, NSNumber *num2) { return [num1 compare:num2]; }
#define DP_BLOCK_CMPNUM_GT  \
            ^(NSNumber *num1, NSNumber *num2) { return [num2 compare:num1]; }
#define DP_BLOCK_CMPNUM  DP_BLOCK_CMPNUM_LT

#define DP_BLOCK_CMPNUM_INDEX0_LT                                        \
            ^(NSArray *arr1, NSArray *arr2) {                            \
              return [(NSNumber *)arr1[0] compare:(NSNumber *)arr2[0]];  \
            }
#define DP_BLOCK_CMPNUM_INDEX0_GT                                        \
            ^(NSArray *arr1, NSArray *arr2) {                            \
              return [(NSNumber *)arr2[0] compare:(NSNumber *)arr1[0]];  \
            }
#define DP_BLOCK_CMPNUM_INDEX0  DP_BLOCK_CMPNUM_INDEX0_LT



#define DP_BLOCK_CMPDATE_LT  \
            ^(NSDate *date1, NSDate *date2) { return [date1 compare:date2]; }
#define DP_BLOCK_CMPDATE_GT  \
            ^(NSDate *date1, NSDate *date2) { return [date2 compare:date1]; }
#define DP_BLOCK_CMPDATE  DP_BLOCK_CMPDATE_LT

#define DP_BLOCK_CMPDATE_INDEX0_LT                                   \
            ^(NSArray *arr1, NSArray *arr2) {                        \
              return [(NSDate *)arr1[0] compare:(NSDate *)arr2[0]];  \
            }
#define DP_BLOCK_CMPDATE_INDEX0_GT                                   \
            ^(NSArray *arr1, NSArray *arr2) {                        \
              return [(NSDate *)arr2[0] compare:(NSDate *)arr1[0]];  \
            }
#define DP_BLOCK_CMPDATE_INDEX0  DP_BLOCK_CMPDATE_INDEX0_LT




//------------------------------------------------ -o-
// Lazy shorthand
//

#define DP_USERDEFAULTS         [NSUserDefaults standardUserDefaults]
#define DP_USERDEFAULTS_SYNC    [DP_USERDEFAULTS synchronize]

#define DP_MAKE_UDKEY(k)        [NSString stringWithFormat:@"__%s", #k]
#define DP_MAKE_UDKEY_STR(k)    [NSString stringWithFormat:@"__%@", k]


#define DP_GSTATE_SAVE()                                         \
    CGContextRef dpCGContextRef = UIGraphicsGetCurrentContext(); \
    CGContextSaveGState(dpCGContextRef);

#define DP_GSTATE_RESTORE() \
    CGContextRestoreGState(UIGraphicsGetCurrentContext());


#define DP_STRWFMT(...)  [NSString stringWithFormat:__VA_ARGS__]

