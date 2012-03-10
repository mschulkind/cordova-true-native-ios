#import "UIViewPlugin.h"

#import "UIUtil.h"

@interface TNUIView : UIView {
}
@end

@implementation TNUIView

@end


@implementation TNUITapGestureRecognizer

@synthesize tnUIID = tnUIID_;

- (id)initWithTarget:(id)target 
              action:(SEL)action 
              tnUIID:(NSString*)tnUIID
            delegate:(id)delegate
{
  if ((self = [super initWithTarget:target action:action])) {
    self.tnUIID = tnUIID;
    self.delegate = delegate;
  }
  return self;
}

- (void)dealloc
{
  self.tnUIID = nil;
  [super dealloc];
}

@end

NSString* const kTNUIViewResizeNotification = @"TNUIViewResize";

static char clickTargetScaleKey;
static char clickTargetWidthKey;
static char clickTargetHeightKey;

BOOL pointInsideWithEvent(
    UIView* self, SEL _cmd, CGPoint point, UIEvent* event);
BOOL pointInsideWithEvent(
    UIView* self, SEL _cmd, CGPoint point, UIEvent* event) {
  NSNumber* clickTargetScaleNumber = 
      objc_getAssociatedObject(self, &clickTargetScaleKey);
  assert(clickTargetScaleNumber);
  float clickTargetScale = [clickTargetScaleNumber floatValue];

  CGRect clickBounds = self.bounds;

  float newWidth = clickBounds.size.width * clickTargetScale;
  float newHeight = clickBounds.size.height * clickTargetScale;

  clickBounds.origin.x -= (newWidth - clickBounds.size.width)/2;
  clickBounds.origin.y -= (newHeight - clickBounds.size.height)/2;
  clickBounds.size.width = newWidth;
  clickBounds.size.height = newHeight;

  // Use height/width overrides if set.
  NSNumber* clickTargetWidth =
      objc_getAssociatedObject(self, &clickTargetWidthKey);
  if (clickTargetWidth) {
    clickBounds.size.width = [clickTargetWidth floatValue];
  }
  NSNumber* clickTargetHeight =
      objc_getAssociatedObject(self, &clickTargetHeightKey);
  if (clickTargetHeight) {
    clickBounds.size.height = [clickTargetHeight floatValue];
  }

  return CGRectContainsPoint(clickBounds, point);
}

@implementation UIViewPlugin

+ (void)initialize
{
  [super initialize];

  [self subclassMethod:@selector(pointInside:withEvent:)
    withImplementation:(IMP)pointInsideWithEvent];
}

+ (Class)uiKitSubclass 
{
  return [TNUIView class];
}

+ (void)fireResizeEventForView:(UIView*)view
{
  NSDictionary* eventData = 
      [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithFloat:view.frame.size.width], @"width",
          [NSNumber numberWithFloat:view.frame.size.height], @"height",
          nil];
  [UIComponentPlugin 
      fireEvent:@"resize" withData:eventData forComponent:view];
}

- (BOOL)gestureRecognizer:(TNUITapGestureRecognizer*)recognizer 
       shouldReceiveTouch:(UITouch*)touch
{
  // Default for overriding in subclasses.
  return TRUE;
}

- (void)onTap:(TNUITapGestureRecognizer*)sender
{
  if (sender.state == UIGestureRecognizerStateEnded) {
    UIView* targetView = [[self class] lookupComponentWithID:sender.tnUIID];

    // Traverse the view hierarchy until we either hit a view that listens
    // clicks, a view that we didn't create, or the end.
    do {
      NSString* tnUIID = [[self class] lookupIDForComponent:targetView];
      if (!tnUIID) {
        break;
      }

      if ([[[self class] writeJavascript:@"listensForEvent('click')"
                            forComponent:targetView] boolValue]) {
        [[self class] fireEvent:@"click" withData:NULL forComponent:targetView];
        break;
      }
    } while((targetView = targetView.superview));
  }
}

- (void)onTouchUpInside:(id)sender
{
  [[self class] fireEvent:@"click" withData:nil forComponent:sender];
}

- (void)setupComponent:(UIView*)view withOptions:(NSDictionary*)options
{
  [super setupComponent:view withOptions:options];

  // Make sure we have a clickTargetScale since there is no default value.
  assert([options objectForKey:@"clickTargetScale"]);

  [self setProperties:
      [NSArray arrayWithObjects:
          @"left", @"top", @"width", @"height", @"centerX", @"centerY",
          @"borderColor", @"borderRadius", @"borderWidth", @"hidden",
          @"backgroundColor", @"backgroundImagePath", @"clickTargetScale", 
          @"clickTargetWidth", @"clickTargetHeight", @"userInteractionEnabled", 
          nil]
      forComponent:view
       fromOptions:options];

  if (![view isKindOfClass:[UIControl class]]) {
    // Add a tap recognizer for to recognize clicks on non-UIControls.
    NSString* tnUIID = [options objectForKey:@"tnUIID"];
    TNUITapGestureRecognizer* tapRecognizer =
        [[TNUITapGestureRecognizer alloc] 
            initWithTarget:self 
                    action:@selector(onTap:) 
                    tnUIID:tnUIID 
                  delegate:self];
    tapRecognizer.cancelsTouchesInView = NO;
    [view addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
  } else {
    // Add a touch up inside target to watch for clicks on UIControls.
    UIControl* control = (UIControl*)view;
    [control addTarget:self 
                action:@selector(onTouchUpInside:)
      forControlEvents:UIControlEventTouchUpInside];
  }

  // Create and add all the child views.
  for (NSDictionary* child in [options objectForKey:@"children"]) {
    [view addSubview:[[self class] componentWithOptions:child]];
  }
}

- (id)getProperty:(NSString*)name 
     forComponent:(TNUIView*)view
{
  if ([name isEqual:@"width"]) {
    return [NSNumber numberWithFloat:view.frame.size.width];
  } else if ([name isEqual:@"height"]) {
    return [NSNumber numberWithFloat:view.frame.size.height];
  } else if ([name isEqual:@"top"]) {
    return [NSNumber numberWithFloat:view.frame.origin.y];
  } else if ([name isEqual:@"left"]) {
    return [NSNumber numberWithFloat:view.frame.origin.x];
  } else {
    return [super getProperty:name forComponent:view];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUIView*)view
{
  if ([name isEqual:@"centerX"]) {
    CGPoint newCenter = view.center;
    newCenter.x = [value floatValue];
    view.center = newCenter;
  } else if ([name isEqual:@"centerY"]) {
    CGPoint newCenter = view.center;
    newCenter.y = [value floatValue];
    view.center = newCenter;
  } else if ([name isEqual:@"top"]) {
    CGRect newFrame = view.frame;
    newFrame.origin.y = [value floatValue];
    view.frame = newFrame;
  } else if ([name isEqual:@"left"]) {
    CGRect newFrame = view.frame;
    newFrame.origin.x = [value floatValue];
    view.frame = newFrame;
  } else if ([name isEqual:@"width"]) {
    CGRect newFrame = view.frame;
    newFrame.size.width = [value floatValue];
    view.frame = newFrame;

    [[NSNotificationCenter defaultCenter] 
        postNotificationName:kTNUIViewResizeNotification
                      object:view];
  } else if ([name isEqual:@"height"]) {
    CGRect newFrame = view.frame;
    newFrame.size.height = [value floatValue];
    view.frame = newFrame;

    [[NSNotificationCenter defaultCenter] 
        postNotificationName:kTNUIViewResizeNotification
                      object:view];
  } else if ([name isEqual:@"backgroundColor"]) {
    view.backgroundColor = [UIUtil colorFromString:value];
    view.opaque = YES;
  } else if ([name isEqual:@"backgroundImagePath"]) {
    if (![value isEqual:@""]) {
      UIImage* image = [UIImage imageNamed:value];
      assert(image);
      view.backgroundColor = [UIColor colorWithPatternImage:image];

      // Grow the view to at least fit the image.
      // TODO(mschulkind): Make this better.
      CGRect newFrame = view.frame;
      newFrame.size.width = MAX(newFrame.size.width, image.size.width);
      newFrame.size.height = MAX(newFrame.size.height, image.size.height);
      view.frame = newFrame;
      [UIViewPlugin fireResizeEventForView:view];

      // Set the view as not opaque so the background image can be transparent.
      view.opaque = NO;
    } else {
      // TODO(mschulkind): Make this better.
      view.backgroundColor = [UIColor whiteColor];
      view.opaque = YES;
    }
  } else if ([name isEqual:@"borderColor"]) {
    view.layer.borderColor = [UIUtil colorFromString:value].CGColor;
  } else if ([name isEqual:@"borderRadius"]) {
    view.layer.cornerRadius = [value floatValue];
  } else if ([name isEqual:@"borderWidth"]) {
    view.layer.borderWidth = [value floatValue];
  } else if ([name isEqual:@"hidden"]) {
    view.hidden = [value boolValue];
  } else if ([name isEqual:@"clickTargetScale"]) {
    objc_setAssociatedObject(
        view, &clickTargetScaleKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  } else if ([name isEqual:@"clickTargetWidth"]) {
    objc_setAssociatedObject(
        view, &clickTargetWidthKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  } else if ([name isEqual:@"clickTargetHeight"]) {
    objc_setAssociatedObject(
        view, &clickTargetHeightKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  } else if ([name isEqual:@"userInteractionEnabled"]) {
    view.userInteractionEnabled = [value boolValue];
  } else {
    [super setProperty:name withValue:value forComponent:view];
  }
}

- (void)add:(NSMutableArray*)arguments
   withDict:(NSMutableDictionary*)options
{
  NSString* parentID = [options objectForKey:@"parentID"];
  UIView* parentView = [[self class] lookupComponentWithID:parentID];
  assert(parentView);

  NSDictionary* childOptions = [options objectForKey:@"child"];
  assert(childOptions);
  UIView* childView = [[self class] componentWithOptions:childOptions];

  [parentView addSubview:childView];

  CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}

- (void)remove:(NSMutableArray*)arguments
      withDict:(NSMutableDictionary*)options
{
  NSString* childID = [options objectForKey:@"childID"];
  UIView* childView = [[self class] lookupComponentWithID:childID];
  assert(childView);

  [childView removeFromSuperview];

  CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}

- (void)bringChildToFront:(NSMutableArray*)arguments
                 withDict:(NSMutableDictionary*)options
{
  NSString* parentID = [options objectForKey:@"parentID"];
  UIView* parentView = [[self class] lookupComponentWithID:parentID];
  assert(parentView);

  NSString* childID = [options objectForKey:@"childID"];
  UIView* childView = [[self class] lookupComponentWithID:childID];
  assert(childView);

  [parentView bringSubviewToFront:childView];
}

- (void)sizeToFit:(NSMutableArray*)arguments
         withDict:(NSMutableDictionary*)options
{
  NSString* viewID = [options objectForKey:@"viewID"];
  UIView* view = [[self class] lookupComponentWithID:viewID];
  assert(view);

  // Using sizeThatFits here becuase sizeToFit has some crazy bugs like only
  // shrinking views (no growing) and changing the origin for no apparent
  // reason.
  CGRect newFrame = view.frame;
  newFrame.size = [view sizeThatFits:newFrame.size];
  view.frame = newFrame;

  CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}

@end
