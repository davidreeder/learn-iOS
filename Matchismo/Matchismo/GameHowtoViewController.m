//
//  GameHowtoViewController.m
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "GameHowtoViewController.h"



//---------------------------------------------------- -o-
@interface GameHowtoViewController()

  @property (weak, nonatomic) IBOutlet  UIWebView  *howtoWebView;

  - (IBAction) backButton:      (id)sender;
  - (IBAction) forwButton:      (id)sender;

@end


#define URL_SETGAME     @"https://en.wikipedia.org/wiki/Set_(game)#Games"
//#define URL_SETGAME     @"https://en.wikipedia.org/wiki/Set_(game)"



//---------------------------------------------------- -o-
@implementation GameHowtoViewController

//------------------- -o-
- (void) viewDidLoad
{
  [super viewDidLoad];
    
  [self.howtoWebView loadRequest:
    [NSURLRequest requestWithURL:[NSURL URLWithString:URL_SETGAME]]];
}


//------------------- -o-
- (IBAction)backButton:(id)sender 
{
  [self.howtoWebView goBack];
}

- (IBAction)forwButton:(id)sender 
{
  [self.howtoWebView goForward];
}

@end // @implementation GameHowtoViewController

