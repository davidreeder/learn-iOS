//
// Dump.h
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2014.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#define DP_VERSION_DUMP  0.6


#import "Danaprajna.h"



//---------------------------------------------------- -o--
#define DP_DUMP_ENABLED  YES    // DEBUG



//---------------------------------------------------- -o--
@interface Dump : NSObject

  // Post string containing one or more of: 
  //   dump label, code location and a message.
  //
  + (void)      msg: (NSString *) msg
           location: (NSString *) location
           category: (NSString *) category;

  + (void)      msg: (NSString *) msg  
           location: (NSString *) location;

  + (void)      msg: (NSString *) msg;

  + (void)      sep;                          // separator




  // Post array of objects named according to their appearance in the code.
  //
  // Macros to convert structs to NSValue.
  // Macros to list single values and lists of values.
  //

  + (NSString *) o: (NSArray *)  arrayOfObjects  
                 l: (NSString *) label
                 s: (NSString *) separator;

  + (NSString *) o: (NSArray *)  arrayOfObjects  
                 l: (NSString *) label;


#define DP_DUMPNV(obj)   @(obj)                            // NSNumber
#define DP_DUMPRV(obj)   [NSValue valueWithRange:   obj]   // NSRange
#define DP_DUMPPV(obj)   [NSValue valueWithCGPoint: obj]   // CGPoint
#define DP_DUMPZV(obj)   [NSValue valueWithCGSize:  obj]   // CGSize
#define DP_DUMPCV(obj)   [NSValue valueWithCGRect:  obj]   // CGRect


#define DP_DUMPN(obj)   [Dump  msg:[Dump o:@[DP_DUMPNV(obj)] l:@ #obj]  location:DP_CODE_LOCATION]
#define DP_DUMPR(obj)   [Dump  msg:[Dump o:@[DP_DUMPRV(obj)] l:@ #obj]  location:DP_CODE_LOCATION]
#define DP_DUMPP(obj)   [Dump  msg:[Dump o:@[DP_DUMPPV(obj)] l:@ #obj]  location:DP_CODE_LOCATION]
#define DP_DUMPZ(obj)   [Dump  msg:[Dump o:@[DP_DUMPZV(obj)] l:@ #obj]  location:DP_CODE_LOCATION]
#define DP_DUMPC(obj)   [Dump  msg:[Dump o:@[DP_DUMPCV(obj)] l:@ #obj]  location:DP_CODE_LOCATION]


#define DP_DUMPO(...)    \
    [Dump  msg:[Dump o:@[ __VA_ARGS__ ]  l:@ #__VA_ARGS__]             location:DP_CODE_LOCATION]
#define DP_DUMPONL(...)  \
    [Dump  msg:[Dump o:@[ __VA_ARGS__ ]  l:@ #__VA_ARGS__  s:@"\n\t"]  location:DP_CODE_LOCATION]



  // Dump NSAttributedString (at index).
  //
  + (void) strAttr: (NSAttributedString *)str;
  + (void) strAttr: (NSAttributedString *)str  index: (NSUInteger)index;




  // Dump arbitrary dictionary with NSStrings for keys.
  // Filter on keys matching prefix.
  //
  + (void)      dict: (NSDictionary *)dict  
          withHeader: (NSString *)header
      matchingPrefix: (NSString *)prefix;

  + (void)      dict: (NSDictionary *)dict  
          withHeader: (NSString *)header;

  + (void)      dict: (NSDictionary *)dict;


  // Combine all entries into a single dictionary to simplify dump output.
  //
#define DP_ONEDICT(dictionary, header, prefix)                              \
  {                                                                         \
    NSMutableDictionary *simpleDict = [[NSMutableDictionary alloc] init];   \
    [simpleDict setObject:dictionary forKey:@""];                           \
    [Dump dict:simpleDict withHeader:header matchingPrefix:prefix];         \
  }
                



  // Macros to mark or insert comments at code locations.
  //
#define DP_MARK()  \
  [Dump  msg:nil                                location:DP_CODE_LOCATION  category:@"_MARK_"]

#define DP_MARKM(...)  \
  [Dump  msg:DP_STRWFMT(__VA_ARGS__)            location:DP_CODE_LOCATION  category:@"_MARK_"]

#define DP_MARKB(...)                                             \
  [Dump    msg: [@"BEGIN " stringByAppendingFormat:__VA_ARGS__ ]  \
      location: DP_CODE_LOCATION                                  \
      category: @"_MARK_"]                              

#define DP_MARKE(...)                                           \
  [Dump    msg: [@"END " stringByAppendingFormat:__VA_ARGS__ ]  \
      location: DP_CODE_LOCATION                                \
      category: @"_MARK_"]




  // Dump file and file system attributes.
  //
  + (void)  urlAttr:              (NSURL *) url;
  + (void)  fileSystemAttrForURL: (NSURL *) url;

#define DP_CURDIR()  [[NSFileManager defaultManager] currentDirectoryPath]

#define DP_CHANGEDIR(url)  \
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:[url path]]


@end // Dump

