#import "FBConnect.h"

@interface FacebookPlugin : CDVPlugin<FBSessionDelegate> {
 @private
  Facebook* facebook_;   
  NSString* loginCallbackID_;
}

- (BOOL)handleOpenFacebookURL:(NSURL*)url;

@property (nonatomic, retain) Facebook* facebook;
@property (nonatomic, retain) NSString* loginCallbackID;

@end
