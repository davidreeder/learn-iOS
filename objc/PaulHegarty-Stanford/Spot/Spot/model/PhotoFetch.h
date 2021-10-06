//
// PhotoFetch.h
//
// Photo and photo tag fetching, management and presentation.
//

#import <UIKit/UIKit.h>

#import "Spot.h"
#import "FlickrFetcher.h"

#import "Danaprajna.h"
#import "DataFileCache.h"



//------------------------------------------------------------ -o-
// enumerated values derived from FlickrFetcher method names
//
typedef enum { 
  PFCategoryLatestGeoreferenced, 
  PFCategoryStanford,
  PFCategoryTopPlaces 
} PFCategory;


#define PF_TAG_EXCEPTION_LIST   @"cs193pspot portrait landscape"


// Keys for UserDefaults and photo entries.
//
#define PF_DICTIONARY_ROOT_KEY   @"Spot"

#define PF_RECENTS_KEY           @"RecentPhotos"
#define PF_RECENTS_UPDATED_KEY   @"IsRecentPhotosUpdated"

#define PF_ENTRY_TIMESTAMP_KEY   @"PHOTOFETCH_TIMESTAMP"


//
#define PF_CACHEDIR_MAXSIZE_MULTIPLIER    3
#define PF_CACHEDIR_MAXSIZE_IPHONE        (PF_CACHEDIR_MAXSIZE_MULTIPLIER * 1024 * 1024)
#define PF_CACHEDIR_MAXSIZE_IPAD          (PF_CACHEDIR_MAXSIZE_IPHONE * 4)



//
#define PF_RECENTS_MAX          10


// NB  recentsList indexes by FLICKR_PHOTO_ID, whereas 
//       photoCache (DataFileCache) indexes by FLICKR_PHOTO_ID+SUFFIX.
//
#define PF_PHOTOENTRY_FILENAME(photoEntry)  \
  [NSString stringWithFormat:@"%@.%@", [photoEntry objectForKey:FLICKR_PHOTO_ID], @"png"]




//------------------------------------------------------------ -o-
@interface PhotoFetch : NSObject

  + (DataFileCache *)   photoCache;
  + (dispatch_queue_t)  photoCacheQueue;

  + (NSArray *) fetchPhotos: (PFCategory) fetchCategory;

  + (NSDictionary *)  tagOccurrenceCount;
  + (NSArray *)       photoArrayPerTagOccurrence: (NSString *)tag;

  + (NSArray *)  recentPhotos;
  + (void)       addToRecentsList: (NSMutableDictionary *)photoEntry;
  + (BOOL)       areRecentPhotosUpdated;
  + (void)       clearRecents;

@end

