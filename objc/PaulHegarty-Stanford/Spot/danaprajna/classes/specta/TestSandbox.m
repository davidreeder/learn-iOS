//
// TestSandbox.m
//
// Manage and query file system assets during testing. 
//
//
// NB
//   . self.workspaceURL and self.workspaceTmpURL may be removed and recreated.
//   . All other top level directories will be created, but never removed.
//   . self.assetURL is a cumulative collection of all assets.
//
// NB  Separate from, but reliant upon, Danaprajna (DP_) suite.
//  
//
// CLASS DEPENDENCIES: Log, Zed
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2014.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------


#import "TestSandbox.h"




//-------------------------------------------------------------- -o-
@interface  TestSandbox()

  @property  (readwrite, strong, nonatomic)  NSURL  *rootURL;
  @property  (readwrite, strong, nonatomic)  NSURL  *assetURL;
  @property  (readwrite, strong, nonatomic)  NSURL  *workspaceURL;
  @property  (readwrite, strong, nonatomic)  NSURL  *workspaceTmpURL;


  @property  (strong, nonatomic)     NSFileManager  *fileManager;

  @property  (readwrite, nonatomic)  NSUInteger      errorCounter;

@end




//-------------------------------------------------------------- -o-
@implementation  TestSandbox

#pragma mark - Constructors.

//------------------------------- -o-
// initWithRootPath:
//
// Define standard directories.
// Change directories to self.workspaceURL.
//
// NB  rootPath may lead with tilde ('~') indicating "home directory".
//
- (id)  initWithRootPath: (NSString *) rootPath
            testOnDevice: (BOOL)       testOnDevice
{
  if (!(self = [super init])) {
    DP_LOG_ERROR(@"[super init] failed.");
    return nil;
  }

  if (!rootPath) {
    DP_LOG_ERROR(@"rootPath is undefined.");
    return nil;
  }


  //
  self.verbose = YES;
  [self clearErrorCounter];


  // Testing on device requires prefixing pathname with "/private"
  //
  if (testOnDevice) 
  {
    NSString  *pathPrefix = @"/private";
    self.rootURL = [NSURL fileURLWithPath: DP_STRWFMT(@"%@%@", pathPrefix, [rootPath stringByExpandingTildeInPath])
                              isDirectory: YES ];
  } else {
    self.rootURL = [NSURL fileURLWithPath:[rootPath stringByExpandingTildeInPath] isDirectory:YES];
  }
  

  self.assetURL         = [self.rootURL URLByAppendingPathComponent:SANDBOX_ASSET_STR isDirectory:YES];
  self.workspaceURL     = [self.rootURL URLByAppendingPathComponent:SANDBOX_WORKSPACE_STR isDirectory:YES];
  self.workspaceTmpURL  = [self.workspaceURL URLByAppendingPathComponent:SANDBOX_WORKSPACE_TMP_STR isDirectory:YES];



  if (! (   [Zed createDirectoryForURL:self.rootURL          replace:YES]
         && [Zed createDirectoryForURL:self.assetURL         replace:YES]
         && [Zed createDirectoryForURL:self.workspaceURL     replace:YES] 
         && [Zed createDirectoryForURL:self.workspaceTmpURL  replace:YES] ))
  {
    return nil;
  }


  //
  [self.fileManager changeCurrentDirectoryPath:[self.workspaceURL path]];
  if (self.verbose) {
    DP_LOG_INFO(@"CURRENT DIRECTORY is \"%@\".", [[self.fileManager currentDirectoryPath] lastPathComponent] );
  }


  return self;

} // initWithRootPath:




//-------------------------------------------------------------- -o-
#pragma mark - Getter/setter.

//------------------------------- -o-
- (NSFileManager *)  fileManager
{
  if (!_fileManager) {
    _fileManager = [[NSFileManager alloc] init];
  }
  return _fileManager;
}




//-------------------------------------------------------------- -o-
#pragma mark - Methods.

//------------------------------- -o-
- (BOOL)  recreateWorkspace
{
  return ([Zed recreateDirectoryForURL:self.workspaceURL] 
             && [Zed createDirectoryForURL:self.workspaceTmpURL replace:YES]);
}


//------------------------------- -o-
- (BOOL)  recreateWorkspaceTmp
{
  return [Zed recreateDirectoryForURL:self.workspaceTmpURL];
}


//------------------------------- -o-
- (BOOL)  removeSandbox
{
  return [Zed removeItemForURL:self.rootURL];
}



//------------------------------- -o-
- (NSInteger)  incrementErrorCounter
{
  return (self.errorCounter += 1);
}


//------------------------------- -o-
- (void)  clearErrorCounter
{
  self.errorCounter = 0;
}



//------------------------------- -o-
- (BOOL)  createFileAsset: (NSString *) fileName
                   ofSize: (NSUInteger) sizeInBytes
              withPattern: (NSString *) fourByteHexPattern
{
  BOOL  rval;

  if ( (!fileName) || ((nil != fourByteHexPattern) && (8 != [fourByteHexPattern length])) )
  {
    DP_LOG_ERROR(@"fileName is nil  -OR-  fourByteHexPattern is not 8 characters.");
    return NO;
  }


  //
  if (!fourByteHexPattern) 
  {
    const char  *hexChar = [@"abcdef0123456789" cStringUsingEncoding:NSASCIIStringEncoding];
    NSString    *randomPattern = @"";

    sranddev();

    for (int i = 8; i > 0; i--) {
      randomPattern = [randomPattern stringByAppendingString:
                        [NSString stringWithFormat:@"%c", hexChar[rand() % 16] ]];
    }

    fourByteHexPattern = randomPattern;
  }


  //
  NSScanner     *scanner = [NSScanner scannerWithString:fourByteHexPattern];
  unsigned int   bytePattern;

  rval = [scanner scanHexInt:&bytePattern];
  if (!rval) {
    DP_LOG_ERROR(@"fourByteHexPattern (\"%@\") is not a hexadecimal number.", fourByteHexPattern);
    return NO;
  }
  bytePattern = (unsigned int) htonl((__uint32_t)bytePattern);

  char  *newData = (char *) malloc(sizeInBytes);
  if (!newData) {
    DP_LOG_ERROR(@"Could not malloc() newData.");
    return NO;
  }

  memset_pattern4((void *)newData, (const void *)&bytePattern, sizeInBytes);


  //
  NSData   *fileData  = [NSData dataWithBytesNoCopy:newData length:sizeInBytes freeWhenDone:YES];
  NSError  *error     = nil;


  rval = [fileData writeToURL:  DP_URL_PLUSFILE(self.assetURL, fileName)
                      options:  NSDataWritingAtomic
                        error: &error ];
  if (error) {
    DP_LOG_NSERROR(error);
  }

  if (!rval) {
    DP_LOG_ERROR(@"Failed to write generated data to assets file.  (%@)", fileName);
    return NO;
  }


  return YES;

} // createFileAsset:ofSize:withPattern: 


@end // @implementation  TestSandbox

