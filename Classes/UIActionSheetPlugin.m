#import "UIActionSheetPlugin.h"

#import "UIWindowPlugin.h"

@interface TNUIActionSheet : UIActionSheet {
 @private
}
@end

@implementation TNUIActionSheet

@end

@implementation UIActionSheetPlugin

- (void)actionSheet:(UIActionSheet*)actionSheet 
  clickedButtonAtIndex:(NSInteger)buttonIndex
{
  NSDictionary* clickData = 
      [NSDictionary dictionaryWithObject:
          [NSNumber numberWithInt:buttonIndex] forKey:@"index"];
  [[self class] fireEvent:@"actionSheetClick" 
                 withData:clickData
             forComponent:actionSheet];
}

+ (Class)uiKitSubclass
{
  return [TNUIActionSheet class];
}

- (void)setupComponent:(TNUIActionSheet*)actionSheet
           withOptions:(NSDictionary*)options
{
  [super setupComponent:actionSheet withOptions:options];

  actionSheet.delegate = self;

  NSArray* buttons = [options objectForKey:@"buttons"];
  if (![buttons isKindOfClass:[NSNull class]]) {
    for (NSDictionary* buttonOptions in buttons) {
      NSString* title = [buttonOptions objectForKey:@"title"];
      assert(title);

      NSInteger buttonIndex = [actionSheet addButtonWithTitle:title];

      NSString* type = [buttonOptions objectForKey:@"type"];
      if (type) {
        if ([type isEqual:@"cancel"]) {
          actionSheet.cancelButtonIndex = buttonIndex;
        } else if ([type isEqual:@"destructive"]) {
          actionSheet.destructiveButtonIndex = buttonIndex;
        } else {
          assert(false);
        }
      }
    }
  }

  [self setProperties:
    [NSArray arrayWithObjects:@"title", nil]
    forComponent:actionSheet
    fromOptions:options];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUIActionSheet*)actionSheet
{
  if (false) {
  } else {
    return [super getProperty:name forComponent:actionSheet];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUIActionSheet*)actionSheet
{
  if ([name isEqual:@"title"]) {
    actionSheet.title = value;
  } else {
    [super setProperty:name 
             withValue:value 
          forComponent:actionSheet];
  }
}

- (void)show:(NSMutableArray*)arguments
    withDict:(NSMutableDictionary*)options
{

  NSDictionary* actionSheetOptions = [options objectForKey:@"actionSheet"];
  TNUIActionSheet* actionSheet = 
      [[self class] componentWithOptions:actionSheetOptions];

  [actionSheet showInView:[UIWindowPlugin topViewController].view];
}

@end
