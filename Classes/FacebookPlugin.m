#import "FacebookPlugin.h"

#import "FBConnect.h"

@implementation FacebookPlugin

@synthesize facebook = facebook_;
@synthesize loginCallbackID = loginCallbackID_;

- (void)dealloc
{
  self.loginCallbackID = nil;
  self.facebook = nil;

  [super dealloc];
}

- (BOOL)handleOpenFacebookURL:(NSURL*)url
{
  return [facebook_ handleOpenURL:url];
}

- (void)setup:(NSMutableArray*)arguments
     withDict:(NSMutableDictionary*)options
{
  NSString* appID = [options objectForKey:@"appID"];
  assert(appID);
  Facebook* facebook = [[Facebook alloc] initWithAppId:appID andDelegate:self];
  self.facebook = facebook;
  [facebook release];
}

- (void)fbDidLogin
{
  CDVPluginResult* result = 
      [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                     messageAsString:facebook_.accessToken];
  [self writeJavascript:[result toSuccessCallbackString:loginCallbackID_]];
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
  CDVPluginResult* result = 
      [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
  [self writeJavascript:[result toErrorCallbackString:loginCallbackID_]];
}

- (void)fbDidLogout
{
  NSLog(@"WARNING: fbDidLogout not supported yet.");
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
  NSLog(@"WARNING: fbDidExtendToken:expiresAt: not supported yet.");
}

- (void)fbSessionInvalidated
{
  NSLog(@"WARNING: fbSessionInvalidated not supported yet.");
}

- (void)login:(NSMutableArray*)arguments 
     withDict:(NSMutableDictionary*)options
{
  assert(facebook_);
  self.loginCallbackID = [arguments objectAtIndex:0];
  NSArray* permissions = [options objectForKey:@"permissions"];

  [facebook_ authorize:permissions];
}

@end
