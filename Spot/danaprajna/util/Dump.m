//
// Dump.m
//
// Output things.  Be useful, and brief.
//
//
// CLASS METHODS--
//   msg:location:category:
//   msg:location:
//   msg:
//   sep
// 
//   o:l:s:
//   o:l:
// 
//   strAttr:
//   strAttr:index:
//
//   dict:withHeader:matchingPrefix:
//   dict:withHeader:
//
//   urlAtrr:
//   fileSystemAttrForURL:
//
//
// MACROS--
//   DP_DUMPNV DP_DUMPRV DP_DUMPPV DP_DUMPZV DP_DUMPCV
//   DP_DUMPN DP_DUMPR DP_DUMPP DP_DUMPZ DP_DUMPC
//   DP_DUMPO DP_DUMPONL
//   DP_ONEDICT
//   DP_MARK DP_MARKM DP_MARKB DP_MARKE
//   DP_CURDIR DP_CHANGEDIR
//
//
// CLASS DEPENDENCIES: Log
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2014.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "Dump.h"



//---------------------------------------------------- -o--
@implementation Dump

// 
// class methods
//

//------------------- -o-
// location:category:msg:
// location:msg:
// msg:
// sep
//

+ (void)      msg: (NSString *) msg
         location: (NSString *) location
         category: (NSString *) category
{
  if (DP_DUMP_ENABLED) {
    NSLog(@"%@ %@ %@ %@", 
      category, location?location:@"", msg?@"--":@"", msg?msg:@"");
  }
}

+ (void)      msg: (NSString *) msg
         location: (NSString *) location  
{
  [Dump  msg:msg  location:location  category:@"_DUMP_"];
}

+ (void) msg: (NSString *) msg
{
  [Dump  msg:msg  location:@""  category:@"_DUMP_"];
}


+ (void) sep
{
  if (DP_DUMP_ENABLED) {
    NSLog(@"--------------------------------------------- -o" "--");
  }
}




//------------------- -o-
// o:l:s:
// o:l:
//
// RETURN  List of objects as a string named according to 
//           their appearance in the code.
//
// ASSUME  Items in label are separated by commas (@",").
//
// EXAMPLES OF USE--
//     DP_DUMPO(<NSObject> -or- <NSString>)
//     DP_DUMPN(<NSNumber>)
//     DP_DUMPR(<NSRange>)
//     ...
//   
//     DP_DUMPO(obj, obj, ...)
//     DP_DUMPONL(obj, obj, ...)  // separate by newline instead of spaces
//
//       When obj does not naturally have a description method, wrap in
//       an appropriate DP_DUMP*V() macro: 
//       DP_DUMPNV(<NSNumber>), DP_DUMPRV(<NSRange>), &c...
//
+ (NSString *) o: (NSArray *)  arrayOfObjects  
               l: (NSString *) label
               s: (NSString *) separator
{
  NSMutableArray  *tokenArray  = [[label componentsSeparatedByString:@","] mutableCopy];
  NSString        *s           = @"";

  if (!separator)  { separator = @"  "; }  // separates each label=value unit


  // ASSUME  arrayOfObjects and tokenArray have the same count.
  //
  for (NSObject *obj in arrayOfObjects) 
  {
    s = [s stringByAppendingString:
          [NSString stringWithFormat: @"%@%@=%@", 
            separator, 
            [tokenArray[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], 
            obj ? obj : @"nil"
          ] ];
    [tokenArray removeObjectAtIndex:0];
  }

  return s;
} 


+ (NSString *) o: (NSArray *)  arrayOfObjects                   // ALIAS
               l: (NSString *) label
{
  return [[self class]  o:arrayOfObjects  l:label  s:@"  "];
}




//------------------- -o-
// strAttr:
// strAttr:index:
//
+ (void)strAttr:(NSAttributedString *)str       // ALIAS
{
  [Dump strAttr:str index:0];
}


+ (void)strAttr:(NSAttributedString *)str  index:(NSUInteger)index
{
  NSDictionary  *dict;
  NSRange        effectiveRange, longestRange;


  // Poll attributes from longest length of str.
  //
  longestRange = NSMakeRange(index, [str length] - index);

  // NB  Raises an NSRangeException if index or any part of rangeLimit
  //     lies beyond the end of the receivers characters.
  //
  dict = [str  attributesAtIndex:  index  
           longestEffectiveRange: &effectiveRange
                         inRange:  longestRange
         ];


  // Dictionary dump header info.
  //
  NSString *scribble = 
    [NSString stringWithFormat:@"ATTRIBUTED STRING :: \"%@\"\n\t:: index=%lu length=%lu",
      [str string], (unsigned long)index, (unsigned long)NSMaxRange(effectiveRange)];

  if (NSMaxRange(effectiveRange) < NSMaxRange(longestRange)) 
  {
    scribble = [scribble stringByAppendingFormat:@" limit=%lu", (unsigned long)NSMaxRange(longestRange)];
  }

  [Dump msg:scribble];


  // Dictionary dump attributes.
  //
  [Dump        dict: dict 
         withHeader: @"(ATTRIBUTED STRING)" 
     matchingPrefix: nil];

} // strAttr:index:



//------------------- -o-
// dict:withHeader:
// dict:withHeader:matchingPrefix:
//
// ASSUMES  Dictionary keys are NSStrings!
//
+ (void)      dict: (NSDictionary *) dict  
        withHeader: (NSString *)     header
    matchingPrefix: (NSString *)     prefix 
{
  NSString *title = header ? header : @"(unnamed)";
  title = DP_STRWFMT(@"_DICTIONARY: %@_", title);


  NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingComparator:DP_BLOCK_CMPSTR_LT];

  if (!sortedKeys) {
    [Dump      msg: [NSString stringWithFormat:@"(empty dictionary)"]
          location: nil
          category: title
    ];

  } else {
    for (id key in sortedKeys) {
      if (prefix && [key isKindOfClass:[NSString class]]) {
        if (! [key hasPrefix:prefix])  { 
          continue; 
        }
      }

      id value = [dict objectForKey:key];
      [Dump      msg: [NSString stringWithFormat:@"%@ : %@", key, value]
            location: nil
            category: title
      ];
    }
  }

} // dict:withHeader:matchingPrefix: 



+ (void)      dict: (NSDictionary *) dict                // ALIAS
        withHeader: (NSString *)     header
{
  [Dump dict:dict withHeader:header matchingPrefix:nil];
}

+ (void)      dict: (NSDictionary *) dict                // ALIAS
{
  [Dump dict:dict withHeader:nil matchingPrefix:nil];
}



//------------------- -o-
+ (void)  urlAttr:(NSURL *)url
{
  NSFileManager  *fm = [NSFileManager defaultManager];
  NSDictionary   *fileDict;
  NSError        *error;

  fileDict = [fm attributesOfItemAtPath:[url path] error:&error];

  if (error) {
    DP_LOG_ERROR(@"[NSFileMasnager attributesOfItemAtPath:error:] failed.");
    DP_LOG_NSERROR(error);

  } else {
    NSString *s = DP_STRWFMT(@"PATH ATTRIBUTES FOR %@", [url absoluteString]);
    DP_ONEDICT(fileDict, s, nil);
  }
}


//------------------- -o-
+ (void)  fileSystemAttrForURL:(NSURL *)url
{
  NSFileManager  *fm = [NSFileManager defaultManager];
  NSDictionary   *fileSystemDict;
  NSError        *error;

  fileSystemDict = [fm attributesOfFileSystemForPath:[url path] error:&error];

  if (error) {
    DP_LOG_NSERROR(error);
    DP_LOG_ERROR(@"[NSFileMasnager attributesOfFileSystemForPath:error:] failed.");

  } else {
    NSString *s = DP_STRWFMT(@"FILE SYSTEM ATTRIBUTES FOR %@", [url absoluteString]);
    DP_ONEDICT(fileSystemDict, s, nil);
  }
}


@end // @implementation Dump

