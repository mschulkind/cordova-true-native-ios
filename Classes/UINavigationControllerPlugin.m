#import "UINavigationControllerPlugin.h"

@interface TNUINavigationController : UINavigationController {
}
@end

@implementation TNUINavigationController

@end

@implementation UINavigationControllerPlugin

+ (Class)uiKitSubclass
{
  return [TNUINavigationController class];
}

- (void)setupComponent:(TNUINavigationController*)navigationController 
           withOptions:(NSDictionary*)options
{
  [super setupComponent:navigationController withOptions:options];

  // Create and push all the windows in the window stack.
  for (NSDictionary* childOptions in [options objectForKey:@"windowStack"]) {
    UIViewController* child = [[self class] componentWithOptions:childOptions];
    [navigationController pushViewController:child animated:NO];
  }

  [self setProperties:
    [NSArray arrayWithObjects:@"titleView", nil]
    forComponent:navigationController
    fromOptions:options];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUINavigationController*)navigationController
{
  if (false) {
  } else {
    return [super getProperty:name forComponent:navigationController];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUINavigationController*)navigationController
{
  if ([name isEqual:@"titleView"]) {
    [navigationController.navigationBar addSubview:
        [[self class] componentWithOptions:value]];
  } else {
    [super setProperty:name 
             withValue:value 
          forComponent:navigationController];
  }
}

- (void)push:(NSMutableArray*)arguments
    withDict:(NSMutableDictionary*)options
{
  NSString* parentID = [options objectForKey:@"parentID"];
  assert(parentID);
  TNUINavigationController* parent = 
      [[self class] lookupComponentWithID:parentID];

  NSDictionary* childOptions = [options objectForKey:@"child"];
  assert(childOptions);
  UIViewController* child = [[self class] componentWithOptions:childOptions];

  [parent pushViewController:child animated:YES];
}

- (void)pop:(NSMutableArray*)arguments
   withDict:(NSMutableDictionary*)options
{
  NSString* parentID = [options objectForKey:@"parentID"];
  assert(parentID);
  TNUINavigationController* parent = 
      [[self class] lookupComponentWithID:parentID];

  [parent popViewControllerAnimated:YES];
}

@end
