#import "UITabPlugin.h"

#import "UIWindowPlugin.h"
#import "UIViewPlugin.h"

@interface TNUITab : UINavigationController {
}
@end

@implementation TNUITab

@end

@implementation UITabPlugin

+ (Class)uiKitSubclass 
{
  return [TNUITab class];
}

- (void)setupComponent:(TNUITab*)tab
           withOptions:(NSDictionary*)options
{
  [super setupComponent:tab withOptions:options];

  // Create the tab bar item.
  NSString* tabBarImagePath = [options objectForKey:@"tabBarImagePath"];
  assert(tabBarImagePath);
  NSString* title = [options objectForKey:@"title"];
  tab.tabBarItem = 
      [[UITabBarItem alloc] 
          initWithTitle:title
                  image:[UIImage imageNamed:tabBarImagePath]
                    tag:0];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUITab*)tab
{
  if (false) {
  } else {
    return [super getProperty:name forComponent:tab];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUITab*)tab
{
  if (false) {
  } else {
    [super setProperty:name withValue:value forComponent:tab];
  }
}

- (void)open:(NSMutableArray*)arguments
    withDict:(NSMutableDictionary*)options
{
  NSLog(@"A UITab is not meant to be opened by itself.");
  assert(false);
}

@end
