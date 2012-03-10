#import "UIWindowPlugin.h"

#import <MessageUI/MFMailComposeViewController.h>

@interface UIMailComposeWindowPlugin : UIWindowPlugin 
    <MFMailComposeViewControllerDelegate> {
 @private
}

@end
