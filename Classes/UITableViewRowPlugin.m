#import "UITableViewRowPlugin.h"

#import "UIUtil.h"

@implementation TNUITableViewRow

@end

@implementation UITableViewRowPlugin

+ (Class)uiKitSubclass 
{
  return [TNUITableViewRow class];
}

- (BOOL)gestureRecognizer:(TNUITapGestureRecognizer*)recognizer 
       shouldReceiveTouch:(UITouch*)touch
{
  TNUITableViewRow* row = [[self class] lookupComponentWithID:recognizer.tnUIID];
  UIView* contentView = row.contentView;
  CGPoint location = [touch locationInView:contentView];
  if (location.x > 0 && location.x < contentView.bounds.size.width
      && location.y > 0 && location.y < contentView.bounds.size.height) {
    return YES;
  } else {
    return NO;
  }
}

- (void)setupComponent:(TNUITableViewRow*)row withOptions:(NSDictionary*)options
{
  // Avoid trying to set width or height.
  NSMutableDictionary* filteredOptions = 
      [NSMutableDictionary dictionaryWithDictionary:options];
  [filteredOptions removeObjectForKey:@"width"];
  [filteredOptions removeObjectForKey:@"height"];

  [super setupComponent:row withOptions:filteredOptions];

  [self setProperties:
      [NSArray arrayWithObjects:
          @"text", @"hasDetail", @"selected", @"color", nil]
      forComponent:row
       fromOptions:options];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUITableViewRow*)row
{
  if ([name isEqual:@"width"]) {
    return [NSNumber numberWithFloat:row.contentView.frame.size.width];
  } else if ([name isEqual:@"height"]) {
    return [NSNumber numberWithFloat:row.contentView.frame.size.height];
  } else {
    return [super getProperty:name forComponent:row];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUITableViewRow*)row
{
  if ([name isEqual:@"width"]) {
    NSLog(@"Can't set row width, change the table view instead.");
    assert(false);
  } else if ([name isEqual:@"height"]) {
    NSLog(@"Individual row height not yet supported");
    assert(false);
  } else if ([name isEqual:@"color"]) {
    row.textLabel.textColor = [UIUtil colorFromString:value];
  } else if ([name isEqual:@"text"]) {
    row.textLabel.text = value;
    // Work around an iOS bug where the label doesn't display if set outside of
    // cellForRow.
    [row setNeedsLayout];
  } else if ([name isEqual:@"hasDetail"]) {
    if ([value boolValue]) {
      row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      row.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
      row.accessoryType = UITableViewCellAccessoryNone;
      row.editingAccessoryType = UITableViewCellAccessoryNone;
    }
  } else if ([name isEqual:@"selected"]) {
    [row setSelected:[value boolValue] animated:YES];
  } else {
    [super setProperty:name withValue:value forComponent:row];
  }
}

@end
