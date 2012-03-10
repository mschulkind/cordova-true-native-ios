#import "UITabControllerPlugin.h"

#import "UITabPlugin.h"

@interface TNUITabController : UITabBarController <UITabBarControllerDelegate> {
}
@end

@implementation TNUITabController

- (BOOL)tabBarController:(TNUITabController*)tabController 
    shouldSelectViewController:(UIViewController*)viewController
{
  // Notify the JS side if the active tab was clicked and iOS is about to
  // automatically pop to the root view controller of a UINavigationController.
  if (tabController.selectedViewController == viewController
      && [viewController isKindOfClass:[UINavigationController class]]) {
    [UIComponentPlugin writeJavascript:@"willPopToRootWindow()"
                          forComponent:viewController];
  }

  return YES;
}

- (void)tabBarController:(TNUITabController *)tabController 
    didSelectViewController:(UIViewController *)viewController
{
  [UIComponentPlugin writeJavascript:
      [NSString stringWithFormat:@"makeActive('%@')",
          [UIComponentPlugin lookupIDForComponent:viewController]]
                        forComponent:tabController];
}

@end

@implementation UITabControllerPlugin

+ (Class)uiKitSubclass 
{
  return [TNUITabController class];
}

- (void)setupComponent:(TNUITabController*)tabController
           withOptions:(NSDictionary*)options
{
  [super setupComponent:tabController withOptions:options];

  tabController.delegate = tabController;
  
  // Create all of the tabs.
  NSMutableArray* tabs = [NSMutableArray arrayWithCapacity:3];
  for (NSDictionary* tabOptions in [options objectForKey:@"tabs"]) {
    assert(
        [[[self class] pluginForComponentWithOptions:tabOptions] class]
        == [UITabPlugin class]);

    [tabs addObject:[[self class] componentWithOptions:tabOptions]];
  }
  tabController.viewControllers = tabs;

  [self setProperties:
      [NSArray arrayWithObjects:@"activeIndex", nil]
      forComponent:tabController
       fromOptions:options];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUITabController*)tabController
{
  if (false) {
  } else {
    return [super getProperty:name forComponent:tabController];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUITabController*)tabController
{
  if ([name isEqual:@"activeIndex"]) {
    tabController.selectedIndex = [value intValue];
  } else {
    [super setProperty:name 
             withValue:value 
          forComponent:tabController];
  }
}

@end
