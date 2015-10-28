//
// PhotoFetch.m
//
// Class methods only.
//

#import "PhotoFetch.h"



//------------------------------------------------------------ -o-
@interface PhotoFetch()

  + (NSArray *) savePhotoArray: (NSArray *) array;
  + (NSArray *) getPhotoArray;

  + (NSArray *) tagsToBeIgnored;

@end




//------------------------------------------------------------ -o--
@implementation PhotoFetch

#pragma mark - Singleton data.

//-------------------------- -o-
+ (NSArray *) savePhotoArray: (NSArray *)array
{
  static NSArray *photoArray = nil;

  if (array)  { photoArray = array; }

  return photoArray;
}


//-------------------------- -o-
+ (NSArray *) getPhotoArray
{
    return [PhotoFetch savePhotoArray:nil];
}



//-------------------------- -o-
+ (DataFileCache *)  photoCache
{
  static DataFileCache  *dfc = nil;

  if (!dfc) {
    long long  cacheSize = [Zed isIPad] ? PF_CACHEDIR_MAXSIZE_IPAD : PF_CACHEDIR_MAXSIZE_IPHONE;
    dfc = [[DataFileCache alloc] initCacheDirectoryWithURL:nil sizeInBytes:cacheSize];
  }

  return dfc;
}
        

//-------------------------- -o-
+ (dispatch_queue_t)  photoCacheQueue
{
  static dispatch_queue_t  cacheOperationsQueue = nil;

  if (!cacheOperationsQueue) 
  {
    DataFileCache  *dfc;
    if (nil == (dfc = [PhotoFetch photoCache])) {
      return nil; 
    }

    cacheOperationsQueue = DP_ASYNC_QUEUE(@"photoCache @ %@", [[dfc cacheDirURL] lastPathComponent]);
  }

  return cacheOperationsQueue;
}



//------------------------------------------------------------ -o--
#pragma mark - Class methods.

//-------------------------- -o-
// fetchPhotos:
//
// NB  Internal state is created, even if return value may be ignored.
//
// ASSUME  Calling environment spawns thread before calling this method. 
//
+ (NSArray *) fetchPhotos: (PFCategory)fetchCategory
{
  switch(fetchCategory) 
  {
    case PFCategoryLatestGeoreferenced:
    {
      [self savePhotoArray:[FlickrFetcher latestGeoreferencedPhotos]];
      break;
    }

    case PFCategoryTopPlaces:
    {
      [self savePhotoArray:[FlickrFetcher topPlaces]];
      break;
    }

    case PFCategoryStanford:
    {
      [self savePhotoArray:[FlickrFetcher stanfordPhotos]];
      break;
    }
  }


  return [[self getPhotoArray] copy];

} // fetchPhotos: 



//-------------------------- -o-
+ (NSArray *) tagsToBeIgnored
{
  static NSString  *exceptionList = PF_TAG_EXCEPTION_LIST;
  return [exceptionList componentsSeparatedByString:@" "];
}



//-------------------------- -o-
+ (NSDictionary *) tagOccurrenceCount
{
  NSMutableDictionary  *tagCountDict  = [[NSMutableDictionary alloc] init];
  BOOL                  isException   = NO;


  for (NSDictionary *entry in [self getPhotoArray])
  {
    for (NSString *tag in [entry[FLICKR_TAGS] componentsSeparatedByString:@" "])
    {
      isException = NO;

      for (NSString *exception in [self tagsToBeIgnored]) {
        if ([tag isEqualToString:exception]) { 
          isException = YES;
          break;
        }
      }

      if (isException)  { continue; }


      // NB   Leverages [nil integerValue] equal to zero.
      //
      NSInteger occurrenceCount = [[tagCountDict objectForKey:tag] integerValue];
      occurrenceCount += 1;
      [tagCountDict setObject:@(occurrenceCount) forKey:tag];

    }
  }

  return tagCountDict;
}



//-------------------------- -o-
// photoArrayPerTagOccurrence: 
//
// NB  Ignores photo entries without tag key/value pair.
//
+ (NSArray *) photoArrayPerTagOccurrence: (NSString *) tag
{
  NSMutableArray  *taggedPhotos = [[NSMutableArray alloc] init];

  for (NSDictionary *entry in [self getPhotoArray])
  {
    NSString  *taglist = [entry objectForKey:FLICKR_TAGS];
    if (!taglist)  { continue; }

    for (NSString *entryTag in [taglist componentsSeparatedByString:@" "])
    {
      if ([tag isEqualToString:entryTag])
      {
        [taggedPhotos addObject:entry];
        break;
      }
    }
  }

  return taggedPhotos;
}



//-------------------------- -o-
+ (NSArray *) recentPhotos
{
  [ZedUD    root: PF_DICTIONARY_ROOT_KEY
       setObject: [NSNumber numberWithBool:NO]
          forKey: PF_RECENTS_UPDATED_KEY];
   
  return [Zed sortedArrayOfDictionaryValues: [ZedUD root:PF_DICTIONARY_ROOT_KEY dictionary:PF_RECENTS_KEY]
                                    withKey: PF_ENTRY_TIMESTAMP_KEY
                                  ascending: NO];
}



//-------------------------- -o-
// addToRecentsList:
//
// Add new, timestamped, entry to recentsList.
// Trim length of recentsList, as necessary.
// Store updated results in UserDefaults.
// 
// NB  Must always be called from the same serial queue.
//
+ (void)  addToRecentsList:(NSMutableDictionary *)newPhotoEntry
{
  NSMutableDictionary  *recentsDict = [ZedUD root:PF_DICTIONARY_ROOT_KEY dictionary:PF_RECENTS_KEY];

  if (!recentsDict) {
    recentsDict = [[NSMutableDictionary alloc] init];
  }


  //
  [newPhotoEntry setObject:DP_DATE_NOW forKey:PF_ENTRY_TIMESTAMP_KEY];
  [recentsDict setObject:newPhotoEntry forKey:[newPhotoEntry objectForKey:FLICKR_PHOTO_ID]];


  if ([recentsDict count] > PF_RECENTS_MAX) 
  {
    NSMutableArray *sortedDictionaryEntries = [Zed sortedArrayOfDictionaryValues: recentsDict
                                                                         withKey: PF_ENTRY_TIMESTAMP_KEY
                                                                       ascending: NO];
    while ([recentsDict count] > PF_RECENTS_MAX) 
    {
      NSString  *oldestEntryId = [[sortedDictionaryEntries lastObject] objectForKey:FLICKR_PHOTO_ID];

      [sortedDictionaryEntries removeLastObject];
      [recentsDict removeObjectForKey:oldestEntryId];
    }
  }


  //
  [ZedUD     root: PF_DICTIONARY_ROOT_KEY 
        setObject: recentsDict 
           forKey: PF_RECENTS_KEY ];

  [ZedUD  root: PF_DICTIONARY_ROOT_KEY 
     setObject: [NSNumber numberWithBool:YES] 
        forKey: PF_RECENTS_UPDATED_KEY ];

} // addToRecentsList:



//-------------------------- -o-
// areRecentPhotosUpdated
//
// NB  Checking the value, clears the value.
//
+ (BOOL) areRecentPhotosUpdated
{
  BOOL  isUpdated = [ZedUD root: PF_DICTIONARY_ROOT_KEY
                           bool: PF_RECENTS_UPDATED_KEY];

  [ZedUD    root: PF_DICTIONARY_ROOT_KEY
       setObject: [NSNumber numberWithBool:NO]
          forKey: PF_RECENTS_UPDATED_KEY];

  return isUpdated;
}



//-------------------------- -o-
+ (void) clearRecents
{
  [ZedUD  udRemoveRootDictionary:PF_DICTIONARY_ROOT_KEY];

  [[PhotoFetch photoCache] clearCache];

  [ZedUD    root: PF_DICTIONARY_ROOT_KEY
       setObject: [NSNumber numberWithBool:YES]
          forKey: PF_RECENTS_UPDATED_KEY];
}


@end // @implementation PhotoFetch

