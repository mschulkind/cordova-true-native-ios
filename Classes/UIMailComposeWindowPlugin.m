#import "UIMailComposeWindowPlugin.h"

#import <MessageUI/MFMailComposeViewController.h>

@interface TNUIMailComposeWindow : MFMailComposeViewController {
 @private
}
@end

@implementation TNUIMailComposeWindow

@end

@implementation UIMailComposeWindowPlugin

- (void)mailComposeController:(MFMailComposeViewController*)mailComposeWindow 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error
{
  [[self class] writeJavascript:@"close()" forComponent:mailComposeWindow];
}

+ (Class)uiKitSubclass
{
  return [TNUIMailComposeWindow class];
}

- (void)setupComponent:(TNUIMailComposeWindow*)mailComposeWindow
           withOptions:(NSDictionary*)options
{
  assert([MFMailComposeViewController canSendMail]);

  [super setupComponent:mailComposeWindow withOptions:options];

  mailComposeWindow.mailComposeDelegate = self;

  [self setProperties:
    [NSArray arrayWithObjects:@"subject", @"messageBody", nil]
    forComponent:mailComposeWindow
    fromOptions:options];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUIMailComposeWindow*)mailComposeWindow
{
  if (false) {
  } else {
    return [super getProperty:name forComponent:mailComposeWindow];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUIMailComposeWindow*)mailComposeWindow
{
  if ([name isEqual:@"subject"]) {
    [mailComposeWindow setSubject:value];
  } else if ([name isEqual:@"messageBody"]) {
    [mailComposeWindow setMessageBody:value isHTML:NO];
  } else {
    [super setProperty:name 
             withValue:value 
          forComponent:mailComposeWindow];
  }
}

- (void)canSendMail:(NSMutableArray*)arguments
           withDict:(NSMutableDictionary*)options
{
  CDVPluginResult* result = 
      [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                        messageAsInt:[MFMailComposeViewController canSendMail]];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}

@end
