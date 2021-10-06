//
// DataFileCache.h
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2014.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import <UIKit/UIKit.h>

#import "Danaprajna.h"



//------------------------------------------------------------ -o-
#define DFC_CACHEDIR_BASENAME_DEFAULT      @"DataFileCache"
#define DFC_CACHEDIR_DATADIR_NAME          @"data"
#define DFC_CACHEDIR_PROPERTYLIST_NAME     @"dataTimestamps.plist"


// SCHEMA for self.propertyList --
//   NSDictionary of zero or more:
//     NSString fileName --> NSNumber timestamp
//
#define DFC_FILE_TIMESTAMP_KEY      @"DATAFILECACHE_TIMESTAMP"




@interface DataFileCache : NSObject
//------------------------------------------------------------ -o-

  @property  (readonly, strong, nonatomic)  NSURL  *cacheDirURL;
  @property  (readonly, strong, nonatomic)  NSURL  *propertyListURL;
  @property  (readonly, strong, nonatomic)  NSURL  *dataDirURL;

  @property  (nonatomic)  BOOL  verbose;
      // YES enables DP_LOG_INFO messages.



  //
  - (id) initCacheDirectoryWithURL: (NSURL *)    cacheDirURL
                       sizeInBytes: (long long)  sizeInBytes;


  - (BOOL) saveFile: (NSString *) fileName
           withData: (NSData *)   fileData;

  - (BOOL) isFileCached: (NSString *)fileName;

  - (NSURL *) cachedFileURL: (NSString *)fileName;

  - (NSInteger)  currentFreeBytes;

  - (BOOL) deleteFile: (NSString *)fileName;

  - (BOOL) makeBytesAvailable: (long long)bytesRequested;

  - (BOOL) clearCache;

@end

