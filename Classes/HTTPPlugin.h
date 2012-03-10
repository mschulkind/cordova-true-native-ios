#import <Cordova/CDVPlugin.h>

#import "ASIHTTPRequest.h"

@interface HTTPPlugin : CDVPlugin <ASIHTTPRequestDelegate> {
 @private
  // Maps requestID -> HTTPRequestMetadata (see HTTPPlugin.m).
  NSMutableDictionary* requestMap_;
}

@property (nonatomic, retain) NSMutableDictionary* requestMap;

@end
