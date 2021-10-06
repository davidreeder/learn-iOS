//
// Zed.m
//
// Kitchen sink.  Put any routines here that do not naturally collect
// into their own class.
//
//
// CLASS METHODS--
//   colorWith255Red:green:blue:alpha:
//   dateFormatFullShort:
//   scaleValue:fromX1:y1:intoX2:y2:invertedMap:rounded:
//   isIPad
//   networkIndicatorEnable:
//
//   shuffleArray:
//   sortTuples:atIndex:withBlock:
//   sortedArrayOfDictionaryValues:withKey:ascending: 
//
//   fileSizeForURL:includeResourceFork:
//   createDirectoryForURL:force: 
//   removeItemAtURL:
//   recreateDirectoryForURL:
//   
//
// CLASS DEPENDENCIES: Log
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2014.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "Zed.h"



//---------------------------------------------------- -o--
@implementation Zed

#pragma mark - Miscellaneous methods.


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
+ (BOOL) isIPad
{
  return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}


//------------------- -o-
// networkIndicatorEnable: 
//
//   RETURN: count of enable requests
//
// Post spinner in status bar for network activity. 
// Keep reference count so early arrivals do not mask continuing network activity. 
//
+ (NSInteger) networkIndicatorEnable: (BOOL)enable
{
  UIApplication     *app          = [UIApplication sharedApplication];
  static NSInteger   enableCount  = 0;

  if (enable) {
    app.networkActivityIndicatorVisible = YES;
    enableCount += 1;

  } else {
    enableCount -= 1;

    if (enableCount <= 0) {
      app.networkActivityIndicatorVisible = NO;
      enableCount = 0;
    }
  }

  return enableCount;
}



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
// NSComparator block, MUST be in the form defined by 
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



//-------------------------- -o-
+ (NSMutableArray *) sortedArrayOfDictionaryValues: (NSDictionary *) dictionary
                                           withKey: (NSString *)     sortKey
                                         ascending: (BOOL)           ascending
{
  NSMutableArray *array = [[NSMutableArray alloc] init];

  for (id key in dictionary) {
    [array addObject:[dictionary objectForKey:key]];
  }

  NSSortDescriptor  *sd      = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
  NSArray           *sdList  = [NSArray arrayWithObjects:sd, nil];

  return [[array sortedArrayUsingDescriptors:sdList] mutableCopy];
}



//------------------- -o-
// fileSizeForURL:includeResourceFork:
//
// RETURNS:
//   -1         on error  -or-  if url is not a file;
//   otherwise  size of file (INCLUDING resource fork per includeResourceFork).
//
// ASSUME  [NSURL checkResourceIsReachableAndReturnError:] returns error for non-files. 
//
+ (NSInteger)  fileSizeForURL: (NSURL *) url
          includeResourceFork: (BOOL) includeResourceFork
{
  if (!url) {
    DP_LOG_ERROR(@"url is nil.");
    return -1;
  }
  

  //
  NSError  *error = nil;
  BOOL      isFile = [url checkResourceIsReachableAndReturnError:&error];

  if (error) {
    DP_LOG_NSERROR(error);
    DP_LOG_ERROR(@"Failed to assess whether URL is file or otherwise.  (%@)", url);
    return -1;
  }

  if (!isFile) {
    DP_LOG_WARNING(@"URL is NOT a file.  (%@)", url);
    return -1; 
  }


  //
  NSDictionary *keyResults = [url resourceValuesForKeys: @[NSURLFileSizeKey, NSURLTotalFileAllocatedSizeKey]
                                                  error: &error];
  if (error) { 
    DP_LOG_NSERROR(error);
    DP_LOG_ERROR(@"Failed to assess file size.  (%@)", url);
    return -1; 
  }


  //
  NSInteger  size;

  if (includeResourceFork) {
    size = [[keyResults objectForKey:NSURLTotalFileAllocatedSizeKey] integerValue];
  } else {
    size = [[keyResults objectForKey:NSURLFileSizeKey] integerValue];
  }

  return size;

} // fileSizeForURL:includeResourceFork:



//-------------------------- -o-
// fileSystemAttributeForURL:attributeName:
//
// RETURN:  Value of attributeName as unsigned long long  -OR-  DP_ULONGLONG_MAX on error.
//
// XXX  Should signal errs with NSException.
//
+ (unsigned long long)  fileSystemAttributeForURL: (NSURL *)url
                                    attributeName: (NSString *)attributeName
{
  NSFileManager  *fileMgr  = [NSFileManager defaultManager];
  NSError        *error    = nil;

  NSDictionary  *fsDict = [fileMgr attributesOfFileSystemForPath:[url path] error:&error];

  if (error) {
    DP_LOG_NSERROR(error);
    DP_LOG_ERROR(@"Failed to acquire file system attributes.  (%@)", url);
    return DP_ULONGLONG_MAX;
  }
  
  return [[fsDict objectForKey:attributeName] unsignedLongLongValue];
}



//-------------------------- -o-
+ (BOOL)  removeItemForURL:(NSURL *) url
{
  NSFileManager  *fileMgr  = [NSFileManager defaultManager];
  NSError        *error    = nil;


  if (! [fileMgr fileExistsAtPath:[url path]]) {
    DP_LOG_WARNING(@"File to be removed does not exist.  (%@)", url);
    return YES;
  }

  if (! [fileMgr removeItemAtPath:[url path] error:&error]) 
  {
    if (error) {
      DP_LOG_NSERROR(error);
    }
    DP_LOG_ERROR(@"Failed to remove URL object.  (%@)", url);
    return NO;
  }

  return YES;
}



//-------------------------- -o-
// createDirectoryForURL:replace: 
//
// RETURNS:  YES  if directory exists or is successfully created;
//           NO   on error or if directoryURL is not a directory and replace is NO.
//
+ (BOOL)  createDirectoryForURL: (NSURL *) directoryURL
                        replace: (BOOL)    replace
{
  if (!directoryURL) {
    DP_LOG_ERROR(@"directoryURL is nil.");
    return NO;
  }


  //
  NSFileManager  *fileMgr  = [NSFileManager defaultManager];
  NSError        *error    = nil;

  BOOL  fsObjectIsDirectory  = NO;
  BOOL  fsObjectExists       = NO;


  fsObjectExists = [fileMgr fileExistsAtPath:[directoryURL path] isDirectory:&fsObjectIsDirectory];
  
  if (fsObjectExists) {
    if (fsObjectIsDirectory) {
      return YES;
    }

    if (!replace) {
      return NO;
    }

    if (! [Zed removeItemForURL:directoryURL]) {
      return NO;
    }
  }


  if (! [fileMgr createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error])
  {
    DP_LOG_NSERROR(error);
    DP_LOG_ERROR(@"Failed to create directory.  (%@)", directoryURL);
    return NO;
  }


  return YES;

} // createDirectoryForURL:replace: 



//-------------------------- -o-
+ (BOOL)  recreateDirectoryForURL:(NSURL *) directoryURL
{
  if (!directoryURL) {
    DP_LOG_ERROR(@"directoryURL is nil.");
    return NO;
  }

  if (! [Zed removeItemForURL:directoryURL]) {
    return NO;
  }

  return [Zed createDirectoryForURL:directoryURL replace:YES];
}



//-------------------------- -o-
// directoryListForURL:
//
// RETURN:  Array of NSURL.
//
+ (NSMutableArray *) directoryListForURL:(NSURL *)directoryURL
{
  if (!directoryURL) {
    DP_LOG_ERROR(@"directoryURL is nil.");
    return nil;
  }


  //
  NSMutableArray  *directoryListing;

  NSFileManager   *fileMgr  = [NSFileManager defaultManager];
  NSError         *error    = nil;


  directoryListing = [[fileMgr contentsOfDirectoryAtURL:  directoryURL
                             includingPropertiesForKeys:  nil
                                                options:  NSDirectoryEnumerationSkipsHiddenFiles
                                                  error: &error]  mutableCopy];
  if (error) {
    DP_LOG_NSERROR(error);
    DP_LOG_ERROR(@"Failed to read directory.  (%@)", directoryURL);
    return nil;
  }

  return directoryListing;
}


@end // Zed

