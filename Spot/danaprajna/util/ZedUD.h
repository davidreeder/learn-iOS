//
// ZedUD.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2014.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#define DP_VERSION_ZEDUD  0.1


#import "Danaprajna.h"



//---------------------------------------------------- -o-
#define DP_ZEDUD_DEBUG_ENABLED  NO       // DEBUG

//
#define DP_USERDEFAULTS         [NSUserDefaults standardUserDefaults]
#define DP_USERDEFAULTS_SYNC()  [DP_USERDEFAULTS synchronize]

#define DP_MAKE_UDKEY(k)        [NSString stringWithFormat:@"__%@", k]



//---------------------------------------------------- -o-
@interface ZedUD : NSObject

  + (NSMutableDictionary *) udGetRootDictionary:(NSString *) rootKey;

  //
  + (NSObject *)   root: (NSString *) rootKey 
                 object: (NSString *) objectKey;

  + (NSMutableArray *)    root: (NSString *) rootKey 
                         array: (NSString *) arrayKey;

  + (NSMutableData *)   root: (NSString *) rootKey 
                        data: (NSString *) dataKey;

  + (NSDate *)   root: (NSString *) rootKey 
                 date: (NSString *) dateKey;

  + (NSMutableDictionary *) root: (NSString *) rootKey 
                      dictionary: (NSString *) dictKey;

  + (NSMutableString *)   root: (NSString *) rootKey 
                        string: (NSString *) stringKey;

  + (NSInteger)  root: (NSString *) rootKey 
              integer: (NSString *) integerKey;
  + (NSUInteger) root: (NSString *) rootKey 
             uInteger: (NSString *) uIntegerKey;

  + (float)    root: (NSString *) rootKey 
              float: (NSString *) floatKey;
  + (double)   root: (NSString *) rootKey 
             double: (NSString *) doubleKey;

  + (BOOL)   root: (NSString *) rootKey 
             bool: (NSString *) boolKey;

  //
  + (void)            root: (NSString *)     rootKey 
         setRootDictionary: (NSDictionary *) dictContent;

  + (void)        root: (NSString *) rootKey
             setObject: (NSObject *) objectContent
             forKey: (NSString *) objectKey;

  //
  + (void) udRemoveRootDictionary: (NSString *) rootKey;

  + (void)             root: (NSString *) rootKey
         removeObjectForKey: (NSString *) objectKey;


@end // ZedUD

