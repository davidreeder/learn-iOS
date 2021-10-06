//
// Log.h
//
// Log macros.
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2014.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#define DP_VERSION_LOG  0.5


#import "Danaprajna.h"



//---------------------------------------------------- -o-
#define DP_LOG_ENABLED        YES 
#define DP_LOG_LOGTYPE_FATAL  @"FATAL"


#define DP_LOG_DEBUG(...)  \
  [Log msg:[NSString stringWithFormat:__VA_ARGS__]  location:DP_CODE_LOCATION  logType:@"DEBUG"]

#define DP_LOG_INFO(...)  \
  [Log msg:[NSString stringWithFormat:__VA_ARGS__]  location:DP_CODE_LOCATION  logType:@"INFO"]

#define DP_LOG_WARNING(...)  \
  [Log msg:[NSString stringWithFormat:__VA_ARGS__]  location:DP_CODE_LOCATION  logType:@"WARNING"]

#define DP_LOG_ERROR(...)  \
  [Log msg:[NSString stringWithFormat:__VA_ARGS__]  location:DP_CODE_LOCATION  logType:@"ERROR"]

#define DP_LOG_FATAL(...)  \
  [Log msg:[NSString stringWithFormat:__VA_ARGS__]  location:DP_CODE_LOCATION  logType:DP_LOG_LOGTYPE_FATAL]


#define DP_LOG_NSERROR(err)  \
  [Log nserror:(NSError *)err  location:DP_CODE_LOCATION  logType:@"NSERROR"]



//---------------------------------------------------- -o-
@interface Log : NSObject

  + (void)      msg: (NSString *) msg
           location: (NSString *) location  
            logType: (NSString *) logType;

  + (void)   nserror: (NSError *)  error
            location: (NSString *) location
             logType: (NSString *) logType;

@end // @interface Log : NSObject

