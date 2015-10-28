//
// ZedUD.m
//
// Shortcuts and wrappers for NSUserDefaults.
//
//
// CLASS METHODS--
//   udGetRootDictionary:
//   root:object:
//   root:array:
//   root:data:
//   root:date:
//   root:dictionary:
//   root:string:
//   root:integer:
//   root:uInteger:
//   root:float:
//   root:double:
//   root:bool:
//   root:setRootDictionary:
//   root:setObject:forKey:
//   udRemoveRootDictionary:
//   root:removeObjectForKey:
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

#import "ZedUD.h"



//---------------------------------------------------- -o--
@implementation ZedUD

#pragma mark - Shortcuts and wrappers for NSUserDefaults.


//------------------- -o-
+ (NSMutableDictionary *) udGetRootDictionary: (NSString *)rootKey
{
  if (!rootKey) {
    DP_LOG_ERROR(@"rootKey is nil!");
    return nil;
  }

  return [[DP_USERDEFAULTS dictionaryForKey:DP_MAKE_UDKEY(rootKey)] mutableCopy ];
}


//------------------- -o-
+ (NSObject *)   root: (NSString *) rootKey 
               object: (NSString *) objectKey
{
  if (!(rootKey && objectKey)) {
    DP_LOG_ERROR(@"rootKey or objectKey is nil!");
    return nil;
  }

  return [[ZedUD udGetRootDictionary:rootKey] objectForKey:objectKey];
}

+ (NSMutableArray *)    root: (NSString *) rootKey 
                       array: (NSString *) arrayKey
{
  return [(NSMutableArray *) [ZedUD root:rootKey object:arrayKey] mutableCopy];
}


+ (NSMutableData *)   root: (NSString *) rootKey 
                      data: (NSString *) dataKey
{
  return [(NSMutableData *) [ZedUD root:rootKey object:dataKey] mutableCopy];
}


+ (NSDate *)   root: (NSString *) rootKey 
               date: (NSString *) dateKey
{
  return (NSDate *) [ZedUD root:rootKey object:dateKey];
}


+ (NSMutableDictionary *) root: (NSString *) rootKey 
                    dictionary: (NSString *) dictKey
{
  return [(NSMutableDictionary *) [ZedUD root:rootKey object:dictKey] mutableCopy];
}


+ (NSMutableString *)   root: (NSString *) rootKey 
                      string: (NSString *) stringKey
{
  return [(NSMutableString *) [ZedUD root:rootKey object:stringKey] mutableCopy];
}


+ (NSInteger)  root: (NSString *) rootKey 
            integer: (NSString *) integerKey
{
  return [((NSNumber *) [ZedUD root:rootKey object:integerKey]) integerValue];
}

+ (NSUInteger) root: (NSString *) rootKey 
           uInteger: (NSString *) uIntegerKey
{
  return [((NSNumber *) [ZedUD root:rootKey object:uIntegerKey]) unsignedIntegerValue];
}


+ (float)    root: (NSString *) rootKey 
            float: (NSString *) floatKey
{
  return [(NSNumber *) [ZedUD root:rootKey object:floatKey] floatValue];
}

+ (double)   root: (NSString *) rootKey 
           double: (NSString *) doubleKey
{
  return [(NSNumber *) [ZedUD root:rootKey object:doubleKey] doubleValue];
}


+ (BOOL)   root: (NSString *) rootKey 
           bool: (NSString *) boolKey
{
  return [(NSNumber *) [ZedUD root:rootKey object:boolKey] boolValue];
}



//------------------- -o-
+ (void)            root: (NSString *)     rootKey 
       setRootDictionary: (NSDictionary *) dictContent
{
  if (!(rootKey && dictContent)) {
    DP_LOG_ERROR(@"rootKey or dictContent is nil!  UserDefaults not written.");
    return;
  }

  [DP_USERDEFAULTS setObject:dictContent forKey:DP_MAKE_UDKEY(rootKey)];
  DP_USERDEFAULTS_SYNC();
}



//------------------- -o-
+ (void)      root: (NSString *) rootKey 
         setObject: (NSObject *) objectContent
            forKey: (NSString *) objectKey
{
  if (!(rootKey && objectContent && objectKey)) {
    DP_LOG_ERROR(
      @"rootkey or objectContent or objectKey is nil!  Object not written.");
    return;
  }


  NSMutableDictionary *dict = [ZedUD udGetRootDictionary:rootKey];

  if (!dict) {
    dict = [[NSMutableDictionary alloc] init];
  }

  [dict setObject:objectContent forKey:objectKey];
  [ZedUD root:rootKey setRootDictionary:dict];
}



//------------------- -o-
+ (void) udRemoveRootDictionary: (NSString *) rootKey
{
  if (!rootKey) {
    DP_LOG_ERROR(@"rootKey is nil!  Dictionary not removed.");
    return;
  }

  [DP_USERDEFAULTS removeObjectForKey:DP_MAKE_UDKEY(rootKey)];

  if (DP_ZEDUD_DEBUG_ENABLED) {
    DP_LOG_INFO(@"DELETED user defaults.  (rootKey=%@)", rootKey);
  }
}


+ (void)              root: (NSString *) rootKey 
        removeObjectForKey: (NSString *) objectKey
{
  if (!(rootKey && objectKey)) {
    DP_LOG_ERROR(@"rootKey or objectKey is nil!  Object not removed.");
    return;
  }


  NSMutableDictionary *dict = [ZedUD udGetRootDictionary:rootKey];

  if (dict) {
    [dict removeObjectForKey:objectKey];
  }
}

@end // ZedUD

