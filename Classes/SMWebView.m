#import "SMWebView.h"

@implementation SMWebView

@synthesize smRuntime = smRuntime_;

- (id)init
{
  if ((self = [super init])) {
    self.smRuntime = 
        [[[SMRuntime alloc] initWithSourceFiles:nil] autorelease];
  }
  return self;
}

- (void)loadSourceFiles:(NSArray*)sourceFiles
{
  [smRuntime_ loadSourceFiles:sourceFiles];

  // Replace the command queue with nativeExec.
  [smRuntime_ writeJavascript:
      @"Cordova.commandQueue = "
       "{push: function(c){window.nativeExec(c)}, length: 2}"];
}

- (NSString*)stringByEvaluatingJavaScriptFromString:(NSString*)string
{
  assert(smRuntime_);
  return [smRuntime_ writeJavascript:string];
}

- (void)loadRequest:(NSURLRequest*)request
{
}

- (void)loadHTMLString:(NSString*)string baseURL:(NSURL*)baseURL
{
}

- (void)dealloc
{
  self.smRuntime = nil;
  [super dealloc];
}

@end
