//
// Zed.h
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2014.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#define DP_VERSION_ZED  0.4


#import "Danaprajna.h"



//---------------------------------------------------- -o-
#define DP_ZED_DEBUG_ENABLED  YES       // DEBUG



//---------------------------------------------------- -o-
@interface Zed : NSObject

  //
  // Miscellaneous methods.
  //

  + (UIColor *) colorWith255Red: (NSUInteger) red
                          green: (NSUInteger) green
                           blue: (NSUInteger) blue
                          alpha: (float)      alpha;

  + (NSString *) dateFormatFullShort: (NSDate *)date;

  + (float) scaleValue: (float)value 
                fromX1: (float)x1  y1: (float)y1 
                intoX2: (float)x2  y2: (float)y2
           invertedMap: (BOOL)invertedMap
               rounded: (BOOL)rounded;

  + (BOOL) isIPad;

  + (NSInteger) networkIndicatorEnable: (BOOL) enable;


  //
  + (NSMutableArray *) shuffleArray: (NSArray *)inputArray;

  + (NSArray *) sortTuples: (NSArray *)    tuples
                   atIndex: (NSUInteger)   index
                 withBlock: (NSComparator) block;

  + (NSMutableArray *) sortedArrayOfDictionaryValues: (NSDictionary *) dictionary
                                             withKey: (NSString *)     sortKey
                                           ascending: (BOOL)           ascending;


  //
  + (NSInteger)  fileSizeForURL: (NSURL *) url
            includeResourceFork: (BOOL)    includeResourceFork;

  + (unsigned long long)  fileSystemAttributeForURL: (NSURL *)url
                                      attributeName: (NSString *)attributeName;

  + (BOOL)  removeItemForURL:(NSURL *)url;

  + (BOOL)  createDirectoryForURL: (NSURL *) directoryURL
                          replace: (BOOL)    replace;

  + (BOOL)  recreateDirectoryForURL:(NSURL *)directoryURL;

  + (NSMutableArray *) directoryListForURL:(NSURL *)directoryURL;


@end // Zed




//------------------------------------------------ -o-
// Common blocks for sorting NSString, NSNumber, NSDate
//

typedef NSComparisonResult (^dp_block_cmpstr_t) (NSString *str1, NSString *str2);

#define DP_BLOCK_CMPSTR_LOCINS_LT  \
            ^(NSString *str1, NSString *str2) { return [str1 localizedCaseInsensitiveCompare:str2]; }
#define DP_BLOCK_CMPSTR_LOCINS_GT  \
            ^(NSString *str1, NSString *str2) { return [str2 localizedCaseInsensitiveCompare:str1]; }

#define DP_BLOCK_CMPSTR_LT  \
            ^(NSString *str1, NSString *str2) { return [str1 compare:str2]; }
#define DP_BLOCK_CMPSTR_GT  \
            ^(NSString *str1, NSString *str2) { return [str2 compare:str1]; }


typedef NSComparisonResult (^dp_block_cmpnum_t) (NSNumber *str1, NSNumber *str2);

#define DP_BLOCK_CMPNUM_LT  \
            ^(NSNumber *num1, NSNumber *num2) { return [num1 compare:num2]; }
#define DP_BLOCK_CMPNUM_GT  \
            ^(NSNumber *num1, NSNumber *num2) { return [num2 compare:num1]; }


typedef NSComparisonResult (^dp_block_cmpdate_t) (NSDate *str1, NSDate *str2);

#define DP_BLOCK_CMPDATE_LT  \
            ^(NSDate *date1, NSDate *date2) { return [date1 compare:date2]; }
#define DP_BLOCK_CMPDATE_GT  \
            ^(NSDate *date1, NSDate *date2) { return [date2 compare:date1]; }



typedef NSComparisonResult (^dp_block_cmpindex0_t) (NSArray *arr1, NSArray *arr2);

#define DP_BLOCK_CMPSTR_INDEX0_LT                                          \
            ^(NSArray *arr1, NSArray *arr2) {                              \
              return [(NSString *)arr1[0] compare:(NSString *)arr2[0]]; }
#define DP_BLOCK_CMPSTR_INDEX0_GT                                          \
            ^(NSArray *arr1, NSArray *arr2) {                              \
              return [(NSString *)arr2[0] compare:(NSString *)arr1[0]]; }


#define DP_BLOCK_CMPNUM_INDEX0_LT                                          \
            ^(NSArray *arr1, NSArray *arr2) {                              \
              return [(NSNumber *)arr1[0] compare:(NSNumber *)arr2[0]]; }
#define DP_BLOCK_CMPNUM_INDEX0_GT                                          \
            ^(NSArray *arr1, NSArray *arr2) {                              \
              return [(NSNumber *)arr2[0] compare:(NSNumber *)arr1[0]]; }


#define DP_BLOCK_CMPDATE_INDEX0_LT                                     \
            ^(NSArray *arr1, NSArray *arr2) {                          \
              return [(NSDate *)arr1[0] compare:(NSDate *)arr2[0]]; }
#define DP_BLOCK_CMPDATE_INDEX0_GT                                     \
            ^(NSArray *arr1, NSArray *arr2) {                          \
              return [(NSDate *)arr2[0] compare:(NSDate *)arr1[0]]; }




//------------------------------------------------ -o-
// Lazy shorthand
//

//
#define DP_STRWFMT(...)  [NSString stringWithFormat:__VA_ARGS__]

#define DP_NS2CSTRING(s)  \
    ((char *) [[NSData dataWithBytes:[s cStringUsingEncoding:NSASCIIStringEncoding]  length:[s length] + 1]  bytes])


#define DP_URL_PLUSFILE(url, fileComponent)  \
    [url URLByAppendingPathComponent:fileComponent isDirectory:NO]

#define DP_URL_PLUSDIR(url, directoryComponent)  \
    [url URLByAppendingPathComponent:directoryComponent isDirectory:YES]



//
#define DP_CLASS_AND_METHOD  \
    [NSString stringWithFormat:@"%@ :: %@", [self class], NSStringFromSelector(_cmd)]

#define DP_CLASS_AND_METHOD_DASH  \
    [NSString stringWithFormat:@"%@ -- ", DP_CLASS_AND_METHOD]


#define DP_CODE_LOCATION  DP_CLASS_AND_METHOD

#define DP_CODE_LOCATION_WITH_MESSAGE(...)  \
    [DP_CLASS_AND_METHOD_DASH stringByAppendingString:[NSString stringWithFormat:__VA_ARGS__]]



//
#define DP_SLEEP(seconds)                          \
  {                                                \
    DP_MARKB(@"SLEEP %@ seconds...", @(seconds));  \
    [NSThread sleepForTimeInterval:seconds];       \
    DP_MARKE(@"SLEEP.");                           \
  }


// Create serial queue.
//
#define DP_ASYNC_QUEUE(...)                                        \
    dispatch_queue_create(                                         \
      DP_NS2CSTRING( DP_CODE_LOCATION_WITH_MESSAGE(__VA_ARGS__) ), \
      NULL )



//
#define DP_DATE_NOW  [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]]

#define DP_ULONGLONG_MAX  ((unsigned long long) -1)


