#import "FilePlugin.h"

@implementation FilePlugin

- (void)read:(NSMutableArray*)arguments
    withDict:(NSMutableDictionary*)options
{
  NSString* filename = [options objectForKey:@"filename"];

  NSString* filePath =
      [[NSBundle mainBundle] pathForResource:filename ofType:nil];  

  NSString* fileContents = 
      [NSString stringWithContentsOfFile:filePath
                                encoding:NSUTF8StringEncoding
                                   error:NULL];

  CDVPluginResult* result =
      [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                     messageAsString:fileContents];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}

@end
