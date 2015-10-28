//
// Log.m
//
// CLASS DEPENDENCIES: Zed, Dump
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2014.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "Log.h"



//---------------------------------------------------- -o-
@implementation Log


//------------------- -o-
+ (void)      msg: (NSString *) msg
         location: (NSString *) location
          logType: (NSString *) logType
{
  if (DP_LOG_ENABLED) {
    NSLog(@"_LOG: %@_ %@ -- %@", logType, location, msg);
  }

  
  if ([logType isEqualToString:DP_LOG_LOGTYPE_FATAL]) 
  {
    BOOL  useAlertOverExceptionOnFatalError = NO;

    UIAlertView  *anAlert = [[UIAlertView alloc] initWithTitle: DP_LOG_LOGTYPE_FATAL
                                                       message: msg
                                                      delegate: nil
                                             cancelButtonTitle: nil
                                             otherButtonTitles: nil ];

    NSException  *exception = [[NSException alloc] initWithName: DP_LOG_LOGTYPE_FATAL
                                                         reason: msg
                                                       userInfo: nil ];

    if (useAlertOverExceptionOnFatalError) 
    {
      dispatch_async(dispatch_get_main_queue(), ^{ [anAlert show]; });
    } else {
      [exception raise];
    }
  }
} 



//------------------- -o-
+ (void)   nserror: (NSError *)  error
          location: (NSString *) location
           logType: (NSString *) logType
{
  if (!error)  { return; }


  NSString *s;

  if (DP_LOG_ENABLED) {
    s =   [NSString stringWithFormat:@"\n\t%@: %@", @"Description", [error localizedDescription]];
    s = [s stringByAppendingString:
          [NSString stringWithFormat:@"\n\t%@: %@", @"Reason", [error localizedFailureReason]]];
    s = [s stringByAppendingString:
          [NSString stringWithFormat:@"\n\t%@: %@", @"Suggestion", [error localizedRecoverySuggestion]]];

    [Log  msg:s  location:location  logType:logType];
    DP_ONEDICT([error userInfo], @"NSERROR userInfo", nil);
  }

} // nserror:location:logType:


@end // @implementation Log

