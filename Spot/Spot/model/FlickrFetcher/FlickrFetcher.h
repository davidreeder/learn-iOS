//
//  FlickrFetcher.h
//
//  Created for Stanford CS193p Winter 2013.  [notated]
//  Copyright 2013 Stanford University
//  All rights reserved.
//

#import <Foundation/Foundation.h>


// tags in the photo dictionaries returned from stanfordPhotos or latestGeoreferencedPhotos
//
#define FLICKR_PHOTO_TITLE        @"title"
#define FLICKR_PHOTO_DESCRIPTION  @"description._content"  // must use valueForKeyPath: on this one
#define FLICKR_PHOTO_ID           @"id"
#define FLICKR_PLACE_NAME         @"_content"
#define FLICKR_LATITUDE           @"latitude"
#define FLICKR_LONGITUDE          @"longitude"
#define FLICKR_PHOTO_OWNER        @"ownername"
#define FLICKR_PHOTO_PLACE_NAME   @"derived_place"         // doesn't work for Stanford photos XXX
#define FLICKR_TAGS               @"tags"


#define NSLOG_FLICKR    NO 
//#define NSLOG_FLICKR    YES     // DEBUG


typedef enum {
  FlickrPhotoFormatSquare         = 1,    // 75x75
  FlickrPhotoFormatLarge          = 2,    // 1024x768
  FlickrPhotoFormatOriginal       = 64    // at least 1024x768
} FlickrPhotoFormat;




//------------------------------------------------- -o--
@interface FlickrFetcher : NSObject

  // get the URL for a Flickr photo given a dictionary of Flickr photo info
  //  (which can be gotten using stanfordPhotos or latestGeoreferencedPhotos)
  //
  + (NSURL *) urlForPhoto: (NSDictionary *)photo 
                   format: (FlickrPhotoFormat)format;


  // fetch recently taken Flickr photo dictionaries
  //
  + (NSArray *) latestGeoreferencedPhotos;
  + (NSArray *) stanfordPhotos;
  + (NSArray *) topPlaces;

@end

