#import "UIWindowPlugin.h"

#import "UIViewPlugin.h"

@interface TNUIWindow : UIViewController {
  // Inidicates if constructView() should be used inside viewWillAppear to
  // construct the window's view. This is true on application startup, or after
  // a view has been unloaded due to memory pressure.
  bool viewNeedsConstructing_;
}
@end

@implementation TNUIWindow

- (id)init
{
  if ((self = [super init])) {
    viewNeedsConstructing_ = YES;
  }
  return self;
}

- (void)loadView
{
  self.view = 
      [UIComponentPlugin componentWithOptions:
          [UIComponentPlugin writeJavascript:@"createView()" 
                                forComponent:self]];
  viewNeedsConstructing_ = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
  if (viewNeedsConstructing_) {
    [UIComponentPlugin writeJavascript:
        [NSString stringWithFormat:@"constructView(%f, %f)",
            self.view.frame.size.width, self.view.frame.size.height]
        forComponent:self];

    viewNeedsConstructing_ = NO;
  }

  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [UIComponentPlugin fireEvent:@"show" withData:NULL forComponent:self.view];

  [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  // For whatever reason, in some cases, viewDidDisappear can be called before
  // view(Will|Did)Appear, so we have to make sure only to try firing the hide
  // event if the view has already been registered.
  if ([UIComponentPlugin lookupIDForComponent:self.view]) {
    [UIComponentPlugin fireEvent:@"hide" withData:NULL forComponent:self.view];
  }

  [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
  [UIComponentPlugin fireEvent:@"destroyView" withData:NULL forComponent:self];
}

@end

@implementation UIWindowPlugin

static NSMutableArray* viewControllerStack = NULL;

+ (UIViewController*)topViewController
{
  return [viewControllerStack lastObject];
}

+ (void)initialize
{
  [super initialize];

  if (!viewControllerStack) {
    viewControllerStack = [[NSMutableArray alloc] init];
  }
}

+ (Class)uiKitSubclass 
{
  return [TNUIWindow class];
}

- (void)setupComponent:(TNUIWindow*)window
           withOptions:(NSDictionary*)options
{
  [super setupComponent:window withOptions:options];

  NSString* title = [options objectForKey:@"title"];
  window.title = title;
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUIWindow*)window
{
  if(false) {
  } else {
    return [super getProperty:name forComponent:window];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUIWindow*)window
{
  if (false) {
  } else {
    [super setProperty:name 
             withValue:value 
          forComponent:window];
  }
}

- (void)open:(NSMutableArray*)arguments
    withDict:(NSMutableDictionary*)options
{
  NSDictionary* windowOptions = [options objectForKey:@"window"];
  assert(windowOptions);

  TNUIWindow* window = [[self class] componentWithOptions:windowOptions];
  UIView* appView = self.viewController.view.superview;

  NSNumber* modal = [options objectForKey:@"modal"];
  if ([modal boolValue]) {
    UIViewController* topViewController = [[self class] topViewController];

    // It's not possible to present a window modally unless we've first opened
    // a non-modal window.
    assert(topViewController);

    [topViewController presentModalViewController:window animated:YES];
  } else {
    // viewWillAppear expects the view's size to be set to the eventually
    // displayed size, but when presenting a window this way, it does not get
    // automatically set, so we set it ourselves.
    window.view.frame = [[UIScreen mainScreen] applicationFrame];

    [appView addSubview:window.view];
    [appView bringSubviewToFront:window.view];
  }

  [viewControllerStack addObject:window];
}

- (void)close:(NSMutableArray*)arguments
     withDict:(NSMutableDictionary*)options
{
  NSString* windowID = [options objectForKey:@"windowID"];
  assert(windowID);
  UIViewController* window = [[self class] lookupComponentWithID:windowID];
  assert(window);

  // If a window was pushed into a navigation controller, it must be popped,
  // not closed.
  assert(!window.navigationController);

  UIViewController* presentingViewController;
  // Previous to iOS 5, parentViewController points to the VC used to a present
  // a modal VC instead of presentingViewController, so we fall back to
  // parentViewController if presentingViewController does not exist..
  if ([window respondsToSelector:@selector(presentingViewController)]) {
    presentingViewController = [window presentingViewController];
  } else {
    presentingViewController = [window parentViewController];
  }

  if (presentingViewController) {
    // If the window has a presenting view controller and it's not part of a
    // navigation controller, then it must have been presented modally.
    [presentingViewController dismissModalViewControllerAnimated:YES];
  } else {
    // This window was presented by adding the view to the main UIWindow, so
    // just remove it.
    [window.view removeFromSuperview];
  }

  assert([viewControllerStack lastObject] == window);
  [viewControllerStack removeLastObject];

  CDVPluginResult* result =
      [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}

@end
