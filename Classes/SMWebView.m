#import "SMWebView.h"

@implementation SMWebView

@synthesize smRuntime = smRuntime_;

static void loadRequest(id self, SEL _cmd) {
}

+ (void)initialize
{
  [super initialize];

  if ([self class] == [SMWebView class]) { 
    NSLog(@"REPLACING");
    Method method = class_getInstanceMethod(
        [CDVCordovaView class], @selector(loadRequest:));
    method_setImplementation(method, (IMP)loadRequest);
  }
}

- (id)initWithSourceFiles:(NSArray*)sourceFiles
{
  if ((self = [super init])) {
    self.smRuntime = 
        [[[SMRuntime alloc] initWithSourceFiles:sourceFiles] autorelease];
  }
  return self;
}

- (NSString*)stringByEvaluatingJavaScriptFromString:(NSString*)string
{
  assert(![string isEqual:@"Cordova.commandQueueFlushing = true"]);
  NSLog(@"%@", string);
  return [self.smRuntime writeJavascript:string];
}

@end
