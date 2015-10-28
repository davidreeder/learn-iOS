//
// Log.m
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "Log.h"



//---------------------------------------------------- -o-
#define LOGTYPE_DEBUG           0
#define LOGTYPE_ERROR           1
#define LOGTYPE_INFO            2
#define LOGTYPE_WARNING         3



//---------------------------------------------------- -o-
@implementation Log


//------------------- -o-
// post:
//
+ (void) post:(NSString *)msg  withLogType:(NSUInteger)logType
{
  NSString *typeStr;

  switch(logType) {
    case LOGTYPE_DEBUG:    typeStr = @"DEBUG";    break; 
    case LOGTYPE_ERROR:    typeStr = @"ERROR";    break; 
    case LOGTYPE_INFO:     typeStr = @"INFO";     break; 
    case LOGTYPE_WARNING:  typeStr = @"WARNING";  break; 
    default:               typeStr = @"UNKNOWN";
  } 

  NSLog(@"%@ -- %@", typeStr, msg);

} // post



//------------------- -o-
+ (void) debugMsg:(NSString *)msg  { 
  [self post:msg withLogType:LOGTYPE_DEBUG]; 
}

+ (void) errorMsg:(NSString *)msg  { 
  [self post:msg withLogType:LOGTYPE_ERROR]; 
}

+ (void) infoMsg:(NSString *)msg  { 
  [self post:msg withLogType:LOGTYPE_INFO]; 
}

+ (void) warnMsg:(NSString *)msg  { 
  [self post:msg withLogType:LOGTYPE_WARNING]; 
}


@end // Log

