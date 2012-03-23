#import <Cordova/CDVCordovaView.h>

#import "SMRuntime.h"

@interface SMWebView : CDVCordovaView {
 @private
  SMRuntime* smRuntime_;
}

@property (nonatomic, retain) SMRuntime* smRuntime;

- (id)initWithSourceFiles:(NSArray*)sourceFiles;
- (NSString*)stringByEvaluatingJavaScriptFromString:(NSString*)string;

@end
