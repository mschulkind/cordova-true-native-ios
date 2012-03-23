#import "SMRuntime.h"

#import <Cordova/CDVCordovaView.h>

@interface SMWebView : CDVCordovaView {
 @private
  SMRuntime* smRuntime_;
}

@property (nonatomic, retain) SMRuntime* smRuntime;

- (void)loadSourceFiles:(NSArray*)sourceFiles;
- (NSString*)stringByEvaluatingJavaScriptFromString:(NSString*)string;

@end
