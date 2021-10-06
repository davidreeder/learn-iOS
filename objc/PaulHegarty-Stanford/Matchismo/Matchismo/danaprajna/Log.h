//
// Log.h
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#define DP_VERSION_LOG  0.5


#import "Danaprajna.h"



//---------------------------------------------------- -o-
@interface Log : NSObject

  + (void) post:(NSString *)msg  withLogType:(NSUInteger)logType;

  + (void) debugMsg: (NSString *)msg;
  + (void) errorMsg: (NSString *)msg;
  + (void) infoMsg:  (NSString *)msg;
  + (void) warnMsg:  (NSString *)msg;

@end // Log

