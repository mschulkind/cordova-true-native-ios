#import "UIButtonPlugin.h"

#import "UIUtil.h"

@interface TNUIButton : UIButton {
}
@end

@implementation TNUIButton

@end

@implementation UIButtonPlugin

+ (Class)uiKitSubclass 
{
  return [TNUIButton class];
}

- (void)setupComponent:(TNUIButton*)button withOptions:(NSDictionary*)options
{
  [super setupComponent:button withOptions:options];

  button.showsTouchWhenHighlighted = YES;

  [self setProperties:
      [NSArray arrayWithObjects:@"title", @"fontColor", 
          @"highlightedBackgroundColor", @"glowsOnTouch", nil]
      forComponent:button
       fromOptions:options];

  button.titleLabel.font = [UIUtil fontFromOptions:options];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUIButton*)button
{
  if (false) {
  } else {
    return [super getProperty:name forComponent:button];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUIButton*)button
{
  if ([name isEqual:@"title"]) {
    [button setTitle:value forState:UIControlStateNormal];
  } else if ([name isEqual:@"fontColor"]) {
    [button setTitleColor:[UIUtil colorFromString:value] 
                 forState:UIControlStateNormal];
  } else if ([name isEqual:@"highlightedBackgroundColor"]) {
    [button setBackgroundImage:
        [UIUtil imageWithColor:[UIUtil colorFromString:value]]
        forState:UIControlStateHighlighted];

    // Set clipsToBounds so the background image doesn't show outside of any
    // rounded borders.
    // TODO(mschulkind): Make this better.
    button.clipsToBounds = YES;
  } else if ([name isEqual:@"glowsOnTouch"]) {
    button.showsTouchWhenHighlighted = [value boolValue];
  } else {
    [super setProperty:name withValue:value forComponent:button];
  }
}

@end
