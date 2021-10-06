//
// DataFileCacheSpec_A.m
//
// Test main functionality of DataFileCache.
//
//
// CLASS DEPENDENCIES:  TestSandbox, Zed
//

#import "Specta.h"

#define EXP_SHORTHAND
#import "Expecta.h"


#import "TestSandbox.h"

#import "DataFileCache.h"



SpecBegin(DataFileCache_A)


//------------------------------------------------------------------------------------- -o-
#define  CACHESIZE_SMALL  1400000
#define  CACHESIZE_LARGE  (CACHESIZE_SMALL * 2)

#define  FILESIZE_SMALL   250000
#define  FILESIZE_MEDIUM  500000
#define  FILESIZE_LARGE   750000




//------------------------------------------------------------------------------------- -o-
describe(@"DataFileCache", 
^{
  __block  TestSandbox  *sandbox;

  __block  NSDictionary  *assetDict;
  __block  NSString      *assetThatDoesntExist;

  __block  NSData  *smallData,
                   *mediumData,
                   *largeData;




  //-------------------------------------------------- -o-
  beforeAll(^{ 
    BOOL  rval;

    //sandbox = [[TestSandbox alloc] initWithRootPath:@"~/testSandbox/" testOnDevice:NO];
    sandbox = [[TestSandbox alloc] initWithRootPath:@"~/testSandbox/" testOnDevice:YES];

    [sandbox recreateWorkspace];  // ALWAYS build DataFileCache from scratch.


    //
    NSString  *smallFilename   = @"smallBlob.bin";
    NSURL     *smallDataURL    = DP_URL_PLUSFILE(sandbox.assetURL, smallFilename);

    rval = [sandbox createFileAsset:smallFilename ofSize:FILESIZE_SMALL withPattern:@"aaa00aaa"];
    ASSERT_OR_COUNTERROR(rval, sandbox);


    NSString  *mediumFilename  = @"mediumBlob.bin";
    NSURL     *mediumDataURL   = DP_URL_PLUSFILE(sandbox.assetURL, mediumFilename);

    rval = [sandbox createFileAsset:mediumFilename ofSize:FILESIZE_MEDIUM withPattern:@"ccc11ccc"];
    ASSERT_OR_COUNTERROR(rval, sandbox);


    NSString  *largeFilename  = @"largeBlob.bin";
    NSURL     *largeDataURL   = DP_URL_PLUSFILE(sandbox.assetURL, largeFilename);

    rval = [sandbox createFileAsset:largeFilename ofSize:FILESIZE_LARGE withPattern:@"eee22eee"];
    ASSERT_OR_COUNTERROR(rval, sandbox);


    //
#   define SMALL      @"small"
#   define MEDIUM     @"medium"
#   define LARGE      @"large"

#   define DATAURL     @"dataURL"
#   define CACHENAME   @"cachedFileName"
#   define DATASIZE    @"sizeData" 
#   define TOTALSIZE   @"sizeTotal"

    assetDict = 
      @{
        SMALL : @{
                     DATAURL   : smallDataURL,
                     CACHENAME : smallFilename,
                     DATASIZE  : @([Zed fileSizeForURL:smallDataURL includeResourceFork:NO]),
                     TOTALSIZE : @([Zed fileSizeForURL:smallDataURL includeResourceFork:YES]),
                },
        MEDIUM : @{
                     DATAURL   : mediumDataURL,
                     CACHENAME : mediumFilename,
                     DATASIZE  : @([Zed fileSizeForURL:mediumDataURL includeResourceFork:NO]),
                     TOTALSIZE : @([Zed fileSizeForURL:mediumDataURL includeResourceFork:YES]),
                },
        LARGE : @{
                     DATAURL   : largeDataURL,
                     CACHENAME : largeFilename,
                     DATASIZE  : @([Zed fileSizeForURL:largeDataURL includeResourceFork:NO]),
                     TOTALSIZE : @([Zed fileSizeForURL:largeDataURL includeResourceFork:YES]),
                  }
      };

    DP_ONEDICT(assetDict, @"assetDict", nil);


    //
    NSError  *error;

    smallData = [NSData dataWithContentsOfURL:smallDataURL options:0 error:&error];
    ASSERT_OR_COUNTERROR(smallData, sandbox);

    mediumData = [NSData dataWithContentsOfURL:mediumDataURL options:0 error:&error];
    ASSERT_OR_COUNTERROR(mediumData, sandbox);

    largeData = [NSData dataWithContentsOfURL:largeDataURL options:0 error:&error];
    ASSERT_OR_COUNTERROR(largeData, sandbox);


    //
    assetThatDoesntExist = @"assetThatDoesntExist";

  }); // beforeAll (describe)



  //------------------------ -o-
  afterAll(^{
    [sandbox removeSandbox];
  });




  //-------------------------------------------------- -o-
  // Files in LARGE cache--
  //   . verify test objects
  //   . initialize size counters
  //   . watch cached files take up space; count them and name them
  //   . check presence of files in, or absent from, the cache
  //   . refresh oldest file; make free large enough to free (second) oldest file
  //   . delete a cached file, twice; check for existence and check for size
  //
  context(@"#1 :: Files in LARGE cache", 
  ^{
    __block  DataFileCache  *dfc;

    __block  long long  cacheMaximumSize,
                        cacheFreeSize;

    __block  NSMutableArray  *dataDirList;

    __block  BOOL  rval;




    //------------------------ -o-
    beforeAll(^{ 
      dfc = [[DataFileCache alloc] initCacheDirectoryWithURL: DP_URL_PLUSDIR(sandbox.workspaceURL, @"cache-large")
                                                 sizeInBytes: CACHESIZE_LARGE];
    }); // beforeAll (context)



    //------------------------ -o-
    it(@"verify test objects", 
    ^{
      expect([sandbox errorCounter]).to.equal(0);
      expect(dfc).notTo.beNil();
    });



    //------------------------ -o-
    it(@"initialize size counters", 
    ^{
      cacheMaximumSize  = CACHESIZE_LARGE;
      cacheFreeSize     = [dfc currentFreeBytes];

      expect(cacheFreeSize).to.equal(cacheMaximumSize);


      //
      long long  sumOfFiles = [assetDict[SMALL][TOTALSIZE] integerValue]
                                + [assetDict[MEDIUM][TOTALSIZE] integerValue]
                                + [assetDict[LARGE][TOTALSIZE] integerValue];

      expect(sumOfFiles).to.beLessThan(cacheMaximumSize);
    });



    //------------------------ -o-
    it(@"watch cached files take up space; count them and name them", 
    ^{
      [dfc saveFile: assetDict[SMALL][CACHENAME]         // SMALL is first file cached (oldest)
           withData: smallData ];

      dataDirList = [Zed directoryListForURL:[dfc dataDirURL]];

      expect(dataDirList).to.haveCountOf(1);
      expect(dataDirList).to.contain(DP_URL_PLUSFILE([dfc dataDirURL], assetDict[SMALL][CACHENAME]));
      
      cacheFreeSize -= [assetDict[SMALL][TOTALSIZE] integerValue];
      expect([dfc currentFreeBytes]).to.equal(cacheFreeSize);


      //
      [dfc saveFile: assetDict[MEDIUM][CACHENAME]         // MEDIUM is second file, second oldest
           withData: mediumData ];

      dataDirList = [Zed directoryListForURL:[dfc dataDirURL]];

      expect(dataDirList).to.haveCountOf(2);
      expect(dataDirList).to.contain(DP_URL_PLUSFILE([dfc dataDirURL], assetDict[MEDIUM][CACHENAME]));

      cacheFreeSize -= [assetDict[MEDIUM][TOTALSIZE] integerValue];
      expect([dfc currentFreeBytes]).to.equal(cacheFreeSize);
    });



    //------------------------ -o-
    it(@"check presence of files in, or absent from, the cache", 
    ^{
      expect([dfc isFileCached:assetDict[SMALL][CACHENAME]]).to.beTruthy();

      expect([dfc isFileCached:assetThatDoesntExist]).to.beFalsy();

      expect([dfc cachedFileURL:assetDict[SMALL][CACHENAME]]).
          to.equal(DP_URL_PLUSFILE([dfc dataDirURL], assetDict[SMALL][CACHENAME]));
    });



    //------------------------ -o-
    it(@"refresh oldest file; make free large enough to free (second) oldest file", 
    ^{
      [dfc saveFile: assetDict[LARGE][CACHENAME]         // LARGE is third file, third oldest
           withData: largeData ];

      dataDirList = [Zed directoryListForURL:[dfc dataDirURL]];
      expect(dataDirList).to.haveCountOf(3);

      cacheFreeSize -= [assetDict[LARGE][TOTALSIZE] integerValue];
      expect([dfc currentFreeBytes]).to.equal(cacheFreeSize);


      //
      [dfc saveFile: assetDict[SMALL][CACHENAME]         // SMALL refreshed, MEDIUM is least recently used
           withData: smallData ];

      dataDirList = [Zed directoryListForURL:[dfc dataDirURL]];
      expect(dataDirList).to.haveCountOf(3);
      expect([dfc currentFreeBytes]).to.equal(cacheFreeSize);


      //
      expect([dfc isFileCached:assetDict[MEDIUM][CACHENAME]]).to.beTruthy();

      rval = [dfc makeBytesAvailable:([dfc currentFreeBytes] + 1)];
      expect(rval).to.beTruthy();

      dataDirList = [Zed directoryListForURL:[dfc dataDirURL]];
      expect(dataDirList).to.haveCountOf(2);

      cacheFreeSize += [assetDict[MEDIUM][TOTALSIZE] integerValue];
      expect([dfc currentFreeBytes]).to.equal(cacheFreeSize);

      expect([dfc isFileCached:assetDict[MEDIUM][CACHENAME]]).to.beFalsy();
    });



    //------------------------ -o-
    it(@"delete a cached file, twice; check for existence and check for size", 
    ^{
      rval = [dfc deleteFile:assetDict[LARGE][CACHENAME]];
      expect(rval).to.beTruthy();

      dataDirList = [Zed directoryListForURL:[dfc dataDirURL]];
      expect(dataDirList).to.haveCountOf(1);

      cacheFreeSize += [assetDict[LARGE][TOTALSIZE] integerValue];
      expect([dfc currentFreeBytes]).to.equal(cacheFreeSize);


      //
      rval = [dfc deleteFile:assetDict[LARGE][CACHENAME]];
      expect(rval).to.beTruthy();

      expect([dfc currentFreeBytes]).to.equal(cacheFreeSize);
    });

  }); // context -- files in LARGE cache




  //-------------------------------------------------- -o-
  // Files in SMALL cache...
  //   . verify test objects
  //   . initialize size counters
  //   . add too many, see LRU discarded; count them and name them
  //   . clear cache
  //
  context(@"#2 :: Files in SMALL cache", 
  ^{
    __block  DataFileCache  *dfc;

    __block  long long  cacheMaximumSize,
                        cacheFreeSize;

    __block  NSMutableArray  *dataDirList;

    __block  BOOL  rval;




    //------------------------ -o-
    beforeAll(^{ 
      dfc = [[DataFileCache alloc] initCacheDirectoryWithURL: DP_URL_PLUSDIR(sandbox.workspaceURL, @"cache-small")
                                                 sizeInBytes: CACHESIZE_SMALL];
    }); // beforeAll (context)



    //------------------------ -o-
    it(@"verify test objects", 
    ^{
      expect([sandbox errorCounter]).to.equal(0);
      expect(dfc).notTo.beNil();
    });



    //------------------------ -o-
    it(@"initialize size counters", 
    ^{
      cacheMaximumSize  = CACHESIZE_SMALL;
      cacheFreeSize     = [dfc currentFreeBytes];

      expect(cacheFreeSize).to.equal(cacheMaximumSize);


      //
      long long  sumOfFiles = [assetDict[SMALL][TOTALSIZE] integerValue]
                                + [assetDict[MEDIUM][TOTALSIZE] integerValue]
                                + [assetDict[LARGE][TOTALSIZE] integerValue];

      expect(sumOfFiles).to.beGreaterThan(cacheMaximumSize);
    });



    //------------------------ -o-
    it(@"add too many, see LRU discarded; count them and name them",
    ^{
      [dfc saveFile: assetDict[SMALL][CACHENAME]                // SMALL is oldest file
           withData: smallData ];

      cacheFreeSize -= [assetDict[SMALL][TOTALSIZE] integerValue];
      expect([dfc currentFreeBytes]).to.equal(cacheFreeSize);


      [dfc saveFile: assetDict[MEDIUM][CACHENAME]               // MEDIUM is second oldest
           withData: mediumData ];

      cacheFreeSize -= [assetDict[MEDIUM][TOTALSIZE] integerValue];
      expect([dfc currentFreeBytes]).to.equal(cacheFreeSize);


      dataDirList = [Zed directoryListForURL:[dfc dataDirURL]];
      expect(dataDirList).to.haveCountOf(2);


      //
      [dfc saveFile: assetDict[LARGE][CACHENAME]
           withData: largeData ];

      cacheFreeSize += [assetDict[SMALL][TOTALSIZE] integerValue];
      cacheFreeSize -= [assetDict[LARGE][TOTALSIZE] integerValue];
      expect([dfc currentFreeBytes]).to.equal(cacheFreeSize);

      dataDirList = [Zed directoryListForURL:[dfc dataDirURL]];
      expect(dataDirList).to.haveCountOf(2);


      rval = [dfc isFileCached:assetDict[SMALL][CACHENAME]];
      expect(rval).to.beFalsy();

      rval = [dfc isFileCached:assetDict[MEDIUM][CACHENAME]];
      expect(rval).to.beTruthy();
    });



    //------------------------ -o-
    it(@"clear cache", 
    ^{
      rval = [dfc clearCache];
      expect(rval).to.beTruthy();
      expect([dfc currentFreeBytes]).to.equal(cacheMaximumSize);

      dataDirList = [Zed directoryListForURL:[dfc dataDirURL]];
      expect(dataDirList).to.haveCountOf(0);
      
      NSInteger  fileSize = [Zed fileSizeForURL:[dfc propertyListURL] includeResourceFork:NO];
      expect(fileSize).to.beGreaterThan(0);
    });


  }); // context -- files in SMALL cache

}); // describe -- DataFileCache


SpecEnd // DataFileCache_A

