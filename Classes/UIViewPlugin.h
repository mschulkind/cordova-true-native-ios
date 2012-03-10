#import "UIComponentPlugin.h"

@interface TNUITapGestureRecognizer : UITapGestureRecognizer {
 @private
  NSString* tnUIID_;
}

@property (nonatomic, retain) NSString* tnUIID;

@end

@interface UIViewPlugin : UIComponentPlugin <UIGestureRecognizerDelegate> {
 @private
}

extern NSString* const kTNUIViewResizeNotification;

+ (void)fireResizeEventForView:(UIView*)view;

@end
