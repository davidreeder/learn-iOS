//
// DataFileCache.m
//
// Manage directory of files as LRU cache.
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2014.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "DataFileCache.h"




//------------------------------------------------------------ -o-
@interface DataFileCache() 

  //
  @property  (readwrite, strong, nonatomic)  NSURL                *cacheDirURL;

  @property  (readwrite, strong, nonatomic)  NSURL                *propertyListURL;
  @property  (strong, nonatomic)             NSMutableDictionary  *propertyList;

  @property  (readwrite, strong, nonatomic)  NSURL                *dataDirURL;
  @property  (strong, nonatomic)             NSMutableArray       *dataDirContents;


  // NB  A signed value allows the case where sum of pre-existing file(s) 
  //     is greater then requested cache size.  (See makeBytesAvailable:.)
  //
  @property  (nonatomic)  long long  cacheSizeMaximumBytes,
                                     cacheSizeFreeBytes;


  // Private system resources for this instance.
  //
  @property  (strong, nonatomic)  NSFileManager     *fileManager;


  // Private methods.
  //
  - (BOOL) sync;

@end




//------------------------------------------------------------ -o--
@implementation DataFileCache

#pragma mark - Constructors

//------------------------ -o-
// initCacheDirectoryWithURL:sizeInBytes: 
//
// INPUTS--
//   cacheDirURL  Valid URL  -OR-  nil to use system path + default basename.
//   sizeInBytes  Size of cache.  
//
//
// DFC_CACHEDIR_BASENAME and DFC_CACHEDIR_DATADIR_NAME are removed if they exist and are not directories.
// If one of data directory or property list does not exist, the other is removed.
// Upon successful return, data directory and property list are consistent with one another.
//
- (id) initCacheDirectoryWithURL: (NSURL *)    cacheDirURL__
                     sizeInBytes: (long long)  sizeInBytes__
{
  // Sanity check inputs.
  // Initialize properties.
  //
  if (sizeInBytes__ < 1)                                       
  {
    DP_LOG_ERROR(@"Cache size must be greater than zero.");
    return nil;
  }

  if (!(self = [super init])) {
    DP_LOG_ERROR(@"[super init] failed.");
    return nil;
  }

  //
  self.cacheDirURL            = cacheDirURL__;
  self.cacheSizeMaximumBytes  = sizeInBytes__;

  self.verbose = NO;



  // Establish pathnames to cacheDir elements.
  // Sanity check and instantiate data directory and property list.
  // If one of data directory or property list is missing, delete the other.
  //
  if (!self.cacheDirURL) {                                      
    NSArray *cacheDirOptions = [self.fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    if ([cacheDirOptions count] < 1) {
      DP_LOG_ERROR(@"Could not acquire path to NSCachesDirectory."); 
      return nil;
    }

    self.cacheDirURL = [cacheDirOptions[0] URLByAppendingPathComponent:DFC_CACHEDIR_BASENAME_DEFAULT isDirectory:YES];
  }


  if (! [Zed createDirectoryForURL:self.cacheDirURL replace:YES]) {
    return nil;
  }

  self.dataDirURL       = [self.cacheDirURL URLByAppendingPathComponent:DFC_CACHEDIR_DATADIR_NAME isDirectory:YES];
  self.propertyListURL  = [self.cacheDirURL URLByAppendingPathComponent:DFC_CACHEDIR_PROPERTYLIST_NAME];


  //
  BOOL  dataPathExists       = NO;
  BOOL  dataPathIsDirectory  = NO;

  self.propertyList  = [[NSDictionary dictionaryWithContentsOfURL:self.propertyListURL] mutableCopy];
  dataPathExists     = [self.fileManager fileExistsAtPath:[self.dataDirURL path] isDirectory:&dataPathIsDirectory];

  NSString  *dataPathErrorMsg = nil;


  if (dataPathExists)
  {
    if (!dataPathIsDirectory) {                                 
      dataPathErrorMsg = DP_STRWFMT(@"REMOVING file with same name as data directory.  (%@)", self.dataDirURL);
    } else if (!self.propertyList) {                            
      dataPathErrorMsg = DP_STRWFMT(@"REMOVING data directory because property list is missing.  (%@)", self.dataDirURL);
    }

  }

  if (self.propertyList) 
  {
    if ((!dataPathExists) || dataPathErrorMsg) {                
      dataPathErrorMsg = DP_STRWFMT(@"REMOVING property list because data directory is missing or corrupt.  (%@)", self.propertyListURL);
    }
  }


  if (dataPathErrorMsg)                                         
  {
    DP_LOG_WARNING(@"%@", dataPathErrorMsg);

    if (! ([Zed removeItemForURL:self.dataDirURL]
             && [Zed removeItemForURL:self.propertyListURL]) )
    {
      return nil;
    }

    dataPathExists = NO;
  }



  // (Re)create property list and data directory
  //    -OR-
  // Check consistency of property list versus data directory.
  //
  long long  sumOfDatafileSizes = 0;


  if (!dataPathExists)  
  {
    if (! [Zed createDirectoryForURL:self.dataDirURL replace:YES]) {
      return nil;
    }

    self.propertyList = [[NSMutableDictionary alloc] init];

    if (self.verbose) {
      DP_LOG_INFO(@"CREATED property list and data directory for cache directory.  (%@)", self.cacheDirURL);
    }


  } else {
    NSDictionary         *dictOfFilesOnRecord  = self.propertyList;
    NSMutableDictionary  *newDict              = [[NSMutableDictionary alloc] init];

    NSMutableArray       *dataDirList          = [Zed directoryListForURL:self.dataDirURL];


    if (!dataDirList)  { return nil; }
    

    // After for-loop--
    //   . newDict is a copy of dictOfFilesOnRecord, but only contains files 
    //       that exist and have a timestamp;
    //   . dataDirList contains files that were not in dictOfFilesOnRecord;
    //   . sumOfDatafileSizes is the total size (including resource forks) of all files 
    //       listed in newDict.
    //
    for (id key in dictOfFilesOnRecord)         
    {
      NSNumber  *timestamp = (NSNumber *)[dictOfFilesOnRecord objectForKey:key];

      if (!timestamp) {                                         
        DP_LOG_WARNING(@"Property list entry missing timestamp.  (%@)", key);
        continue;
      }

      NSURL  *dataDirEntry = [self.dataDirURL URLByAppendingPathComponent:key];
      if (![dataDirList containsObject:dataDirEntry]) {         
        DP_LOG_WARNING(@"Property list entry missing in data directory.  (%@)", key);
        continue;
      } 

      //
      NSInteger  dataDirEntryFileSize = [Zed fileSizeForURL:dataDirEntry includeResourceFork:YES];

      if (dataDirEntryFileSize < 0)                             
      {
        DP_LOG_WARNING(@"File in data directory is corrupt or missing.  (%@)", key);

        if (! [Zed removeItemForURL:dataDirEntry]) {            
          DP_LOG_ERROR(@"Could not remove errant data directory file.  (%@)", key);
          return nil;  // XXX -- Option to let this slide?
        }

        [dataDirList removeObject:dataDirEntry];
        continue;

      } else {
        sumOfDatafileSizes += dataDirEntryFileSize;
      }

      //
      [dataDirList removeObject:dataDirEntry];
      [newDict setObject:timestamp forKey:key];

    } // endfor


    //
    self.propertyList = newDict;

    if (![self.propertyList writeToURL:self.propertyListURL atomically:YES]) 
    {
      DP_LOG_ERROR(@"Failed to write property list after synchronizing with data directory.  (%@)", self.propertyListURL); 
      return nil;
    }


    //
    if ([dataDirList count] > 0)                                
    {
      __block  BOOL  stopped = NO;

      [dataDirList enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop)
        {
          if (! [Zed removeItemForURL:obj]) {
            stopped  = YES;
            *stop    = YES;
          }
        }];

      if (stopped) {                                            
        DP_LOG_ERROR(@"Failed to remove data file(s) that do not appear in property list.");
        return nil;  // XXX -- Option to let this slide?
      }
    } 

  } // endifelse !dataPathExists 



  // Compute maximum and free bytes.
  //
  if (sumOfDatafileSizes > self.cacheSizeMaximumBytes)          
  {
    long long  difference = (sumOfDatafileSizes - self.cacheSizeMaximumBytes);

    DP_LOG_WARNING(@"Sum of previously cached data (%lld) is greater than cache size.  DELETING cached items...", difference);

    self.cacheSizeFreeBytes = -difference;

    if (! [self makeBytesAvailable:0]) {
      DP_LOG_ERROR(@"Failed to free enough space for request cache size.");
      return nil;
    }

  } else {
    self.cacheSizeFreeBytes = self.cacheSizeMaximumBytes - sumOfDatafileSizes;
  }


  //
  unsigned long long  fileSystemFreeBytes = 
                        [Zed fileSystemAttributeForURL: self.cacheDirURL
                                         attributeName: NSFileSystemFreeSize ]; 
  if (DP_ULONGLONG_MAX == fileSystemFreeBytes)  { return nil; }


  if (self.cacheSizeFreeBytes > fileSystemFreeBytes)            
  {
    DP_LOG_ERROR(
      @"Cache size request (%lld) exceeds sum of previously cached data (%lld) and current file system availability (%llu).",
          self.cacheSizeMaximumBytes, sumOfDatafileSizes, fileSystemFreeBytes);
    return nil;
  }


  return self;

} // initCacheDirectoryWithURL:dataFileSuffix:sizeInBytes: 




//------------------------------------------------------------ -o--
#pragma mark - Getters/setters.

//----------------- -o-
- (NSFileManager *)  fileManager
{
  if (!_fileManager) {
    _fileManager = [[NSFileManager alloc] init];
  }

  return _fileManager;
}




//------------------------------------------------------------ -o--
#pragma mark - Methods.

//----------------- -o-
- (BOOL) saveFile: (NSString *) fileName
         withData: (NSData *)   fileData
{
  if ((!fileName) || (!fileData)) {                             
    DP_LOG_ERROR(@"Undefined arguments: fileName and/or fileData.");
    return NO;
  }


  //
  if ([self isFileCached:fileName])  
  {
    [self.propertyList setObject:DP_DATE_NOW forKey:fileName];
    if (! [self sync])  { return NO; };

    if (self.verbose) {
      DP_LOG_INFO(@"Refreshed timestamp on cached entry.  (%@)", fileName); 
    }

    return YES;
  }


  //
  if (! [self makeBytesAvailable:[fileData length]])
  {
    DP_LOG_ERROR(@"Failed to acquire space sufficient to cache data for \"%@\".", fileName);
    return NO;
  }


  NSURL  *fileURL = DP_URL_PLUSFILE(self.dataDirURL, fileName);

  if (! [fileData writeToURL:fileURL atomically:YES])
  {
    DP_LOG_ERROR(@"Failed to write cache data for \"%@\".", fileName);
    return NO;
  }

  NSInteger fileSize = [Zed fileSizeForURL:fileURL includeResourceFork:YES];
  if (fileSize < 0) {                                   
    DP_LOG_ERROR(@"Failed to read size of cached file \"%@\".  DELETING from cache...", fileName);

    if (! [self deleteFile:fileName]) {
      DP_LOG_ERROR(@"Failed to remove improperly logged cached file \"%@\".", fileName);
    }

    return NO;
  }


  [self.propertyList setObject:DP_DATE_NOW forKey:fileName];
  [self sync]; 
  
  self.cacheSizeFreeBytes -= fileSize;


  return YES;

} // saveFile:withData: 



//----------------- -o-
- (BOOL) isFileCached:(NSString *)fileName
{
  if (nil != [self.propertyList objectForKey:fileName]) {
    return YES;
  }

  return NO;
}



//----------------- -o-
- (NSURL *) cachedFileURL: (NSString *)fileName
{
  if (! [self isFileCached:fileName]) {
    return nil;
  } 

  return DP_URL_PLUSFILE(self.dataDirURL, fileName);
}



//----------------- -o-
- (NSInteger)  currentFreeBytes
{
  return self.cacheSizeFreeBytes;
}



//----------------- -o-
// deleteFile:
//
// RETURN:  YES if file is not cached; NO otherwise.
//
// NB  Deleting non-existent files returns YES.
//
- (BOOL) deleteFile:(NSString *)fileName
{
  if (!fileName) {                                      
    DP_LOG_ERROR(@"fileName is undefined.");
    return NO;
  }


  //
  if (! [self isFileCached:fileName]) {
    return YES;
  }


  //
  NSURL      *fileURL   = DP_URL_PLUSFILE(self.dataDirURL, fileName);
  NSInteger   fileSize  = [Zed fileSizeForURL:fileURL includeResourceFork:YES];

  if (fileSize < 0)  { return NO; }                     

  if (! [Zed removeItemForURL:fileURL])  { return NO; }

  [self.propertyList removeObjectForKey:fileName];
  if (! [self sync])  { return NO; }                    

  self.cacheSizeFreeBytes += fileSize;


  return YES;
}



//----------------- -o-
// makeBytesAvailable:
//
// Make list of file(s) to delete to free up space.
// Determine if needed space, though less than cache size, is also available in the file system.
// Delete file(s) and free space in cache. 
//
// NB  File deletion postponed until all error checks are complete.
//
- (BOOL) makeBytesAvailable:(long long) bytesRequested
{
  if (bytesRequested < 0) {                             
    DP_LOG_ERROR(@"bytesRequested is less than zero.  (%lld)", bytesRequested);
    return NO;
  }


  //
  if (bytesRequested > self.cacheSizeMaximumBytes)      
  {
    DP_LOG_ERROR(@"Size of free space request (%lld) is greater than cache size (%lld).",
                     bytesRequested, self.cacheSizeMaximumBytes);
    return NO;
  }

  if (bytesRequested <= self.cacheSizeFreeBytes) {      
    return YES; 
  }


  //
  NSArray         *sortedKeys                 = [self.propertyList keysSortedByValueUsingComparator:DP_BLOCK_CMPNUM_LT];
  NSMutableArray  *filesScheduledForDeletion  = [[NSMutableArray alloc] init];

  long long  wouldBeFreeBytes = self.cacheSizeFreeBytes;
  NSInteger  fileSize;
        
  for (NSString *key in sortedKeys)
  { 
    if (bytesRequested <= wouldBeFreeBytes) {
      break;
    }

    fileSize = [Zed    fileSizeForURL: DP_URL_PLUSFILE(self.dataDirURL, key)
                  includeResourceFork: YES ];
    if (fileSize < 0)  { return NO; }

    wouldBeFreeBytes += fileSize;
    [filesScheduledForDeletion addObject:key];
  }


  //
  unsigned long long  fileSystemFreeBytes = [Zed fileSystemAttributeForURL: self.dataDirURL
                                                             attributeName: NSFileSystemFreeSize ]; 
  if (DP_ULONGLONG_MAX == fileSystemFreeBytes)  { return NO; }

  if (wouldBeFreeBytes > fileSystemFreeBytes) {
    DP_LOG_ERROR(@"Cache requires more bytes (%lld) than available in file system (%llu).",
                     wouldBeFreeBytes, fileSystemFreeBytes);
    return NO;
  }


  //
  for (NSString *fileName in filesScheduledForDeletion) {
    if (! [self deleteFile:fileName]) {
      return NO;
    }
  }


  return YES;

} // makeBytesAvailable:



//----------------- -o-
- (BOOL) clearCache
{
  self.propertyList = [[NSMutableDictionary alloc] init];
  if (! [self sync]) { 
    return NO; 
  }

  self.cacheSizeFreeBytes = self.cacheSizeMaximumBytes;

  if (! [Zed recreateDirectoryForURL:self.dataDirURL])
  { 
    DP_LOG_ERROR(@"Failed to delete and recreate data directory for cache.");
    return NO; 
  }

  if (self.verbose) {
    DP_LOG_INFO(@"REMOVED and RE-CREATED property list and data directory for cache directory.  (%@)", self.cacheDirURL);
  }

  return YES;
}



//----------------- -o-
- (BOOL) sync
{
  if (! [self.propertyList writeToURL:self.propertyListURL atomically:YES])
  {
    DP_LOG_ERROR(@"Failed to write property list for cache data.  (%@)", self.propertyListURL);
    return NO;
  }

  return YES;
}


@end // @implementation DataFileCache

