#import "MBProgressHUDPlugin.h"

#import "MBProgressHUD.h"

@implementation MBProgressHUDPlugin

@synthesize hud = hud_;

- (void)dealloc
{
  self.hud = nil;

  [super dealloc];
}

- (void)show:(NSMutableArray*)arguments
    withDict:(NSMutableDictionary*)options
{
  NSString *label = [options objectForKey:@"label"];

  UIView* superview = [[self appDelegate] window];
  self.hud = [[[MBProgressHUD alloc] initWithView:superview] autorelease];
  [superview addSubview:hud_];
  hud_.removeFromSuperViewOnHide = YES;
  if (label) {
    hud_.labelText = label;
  }

  [hud_ show:YES];
}

- (void)hide:(NSMutableArray*)arguments
    withDict:(NSMutableDictionary*)options
{
  [hud_ hide:YES];
}

@end
