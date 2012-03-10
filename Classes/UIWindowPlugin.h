#import "UIComponentPlugin.h"

@interface UIWindowPlugin : UIComponentPlugin {
 @private
}

+ (UIViewController*)topViewController;
- (void)open:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
