#import "MBProgressHUD.h"

@interface MBProgressHUDPlugin : CDVPlugin {
 @private
  MBProgressHUD* hud_;
}

@property (nonatomic, retain) MBProgressHUD* hud;

@end
