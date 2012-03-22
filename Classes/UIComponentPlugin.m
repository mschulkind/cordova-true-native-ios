#import "UIComponentPlugin.h"

#import <Cordova/CDVViewController.h>
#import "QSStrings.h"

static void dealloc(id self, SEL _cmd) {
  [UIComponentPlugin writeJavascript:@"unregister()" forComponent:self];
  [UIComponentPlugin unregisterComponent:self];

  IMP originalDealloc = 
      [UIComponentPlugin getOriginalImplementation:(IMP)dealloc
                                       forSelector:_cmd
                                           andSelf:self];
  originalDealloc(self, _cmd);
}

@implementation UIComponentPlugin

// Maps tnUIID -> component (TNUI* class).
static NSMutableDictionary* componentMap = NULL;
static char tnUIIDKey;

// TrueNative doesn't support multiple Cordova instances, so we store what will
// be the one and only UIComponentPlugin instance.
static UIComponentPlugin* uiComponentPluginInstance = NULL; 

+ (void)initialize
{
  if (!componentMap) {
    componentMap = [[NSMutableDictionary alloc] init];
  }

  // Avoid trying to subclass a method for UICompomentPlugin because it's
  // really an abstract base class as far as subclassMethod is concerned.
  if ([self class] != [UIComponentPlugin class]) {
    [self subclassMethod:@selector(dealloc) withImplementation:(IMP)dealloc];
  }
}

- (CDVPlugin*)initWithWebView:(UIWebView*)theWebView
{
  if ((self = [super initWithWebView:theWebView])) {
    if ([self class] == [UIComponentPlugin class]) {
      // We should only ever have one instance.
      assert(uiComponentPluginInstance == NULL);
      uiComponentPluginInstance = self;
    }
  }
  return self;
}

#import "EncodedJavascript.h"
- (void)loadJavascript:(NSMutableArray*)arguments
              withDict:(NSMutableDictionary*)options
{
  NSData* sourceData = [QSStrings decodeBase64WithString:encodedJavascript];
  NSString* source = 
      [[[NSString alloc] 
          initWithData:sourceData encoding:NSUTF8StringEncoding] autorelease];
  [self writeJavascript:source];

  CDVPluginResult* result =
      [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}

+ (void)subclassMethod:(SEL)selector
    withImplementation:(IMP)subclassedImplementation
{
  Method uiKitMethod = class_getInstanceMethod([self uiKitSubclass], selector);
  assert(uiKitMethod);
  BOOL methodAdded = 
      class_addMethod(
        [self uiKitSubclass], selector, subclassedImplementation,
        method_getTypeEncoding(uiKitMethod));

  // If the method wasn't added (because it already exists), we replace the
  // method and save the original implementation for later.
  if (!methodAdded) {
    Method method = class_getInstanceMethod([self uiKitSubclass], selector);

    IMP originalImplementation = 
        method_setImplementation(method, subclassedImplementation);

    objc_setAssociatedObject(
        [self uiKitSubclass], (void*)subclassedImplementation,
        [NSValue valueWithPointer:(void*)originalImplementation],
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
}

+ (IMP)getOriginalImplementation:(IMP)subclassedImplementation
                     forSelector:(SEL)selector
                         andSelf:(id)aSelf
{
  // First check for a saved implementation.
  NSValue* originalImplementation =
      objc_getAssociatedObject(
          [aSelf class], (void*)subclassedImplementation);
  if (originalImplementation) {
    return (IMP)[originalImplementation pointerValue];
  } else {
    // Otherwise return super's implementation if it exists.
    Class superclass = class_getSuperclass([aSelf class]);
    Method superMethod = class_getInstanceMethod(superclass, selector);
    if (superMethod) {
      return method_getImplementation(superMethod);
    } else {
      return NULL;
    }
  }
}

+ (Class)uiKitSubclass {
  assert(false);
}

+ (void)registerComponent:(id)component withID:(NSString*)tnUIID
{
  assert([self lookupComponentWithID:tnUIID] == nil);
  [componentMap setObject:[NSValue valueWithNonretainedObject:component]
                   forKey:tnUIID];
  objc_setAssociatedObject(
      component, &tnUIIDKey, tnUIID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)registerComponent:(id)component withOptions:(NSDictionary*)options
{
  NSString* tnUIID = [options objectForKey:@"tnUIID"];
  assert(tnUIID);
  [self registerComponent:component withID:tnUIID];
}

+ (void)unregisterComponent:(id)component
{
  NSString* tnUIID = [self lookupIDForComponent:component];
  assert(tnUIID);
  [componentMap removeObjectForKey:tnUIID];
}

+ (id)lookupComponentWithID:(NSString*)tnUIID
{
  return [[componentMap objectForKey:tnUIID] nonretainedObjectValue];
}

+ (id)lookupComponentWithOptions:(NSDictionary*)options
{
  NSString* tnUIID = [options objectForKey:@"tnUIID"];
  assert(tnUIID);
  return [self lookupComponentWithID:tnUIID];
}

+ (NSString*)lookupIDForComponent:(id)component
{
  return objc_getAssociatedObject(component, &tnUIIDKey);
}

+ (id)pluginForComponentWithOptions:(NSDictionary*)options
{
  return 
      [[uiComponentPluginInstance commandDelegate] getCommandInstance:
          [options objectForKey:@"pluginID"]];
}

+ (id)writeJavascript:(NSString*)javascript
{
  // Construct and run the javascript. Wraps the result in an array before
  // encoding the JSON since JSONKit doesn't deal well with non-objects.
  NSString* wrappedJavascript = 
      [NSString stringWithFormat:@"JSON.stringify([%@])", javascript];
  NSString* resultJSON = 
      [uiComponentPluginInstance writeJavascript:wrappedJavascript];

  // Flush any commands that just got queue up.
  [(CDVViewController*)uiComponentPluginInstance.viewController 
      flushCommandQueue];

  // Parse, extract, and return the result.
  return [[resultJSON objectFromJSONString] objectAtIndex:0];
}

+ (id)writeJavascript:(NSString*)javascript
    forComponentWithID:(NSString*)tnUIID
{
  assert(tnUIID && ![tnUIID isKindOfClass:[NSNull class]]);

  NSString* wrappedJavascript = 
      [NSString stringWithFormat:
          @"TN.UI.componentMap['%@'].%@",
          tnUIID, javascript];

  return [self writeJavascript:wrappedJavascript];
}

+ (id)writeJavascript:(NSString*)javascript
         forComponent:(id)component
{
  return [self writeJavascript:javascript 
     forComponentWithID:[self lookupIDForComponent:component]];
}

+ (void)fireEvent:(NSString*)name 
      withData:(NSDictionary*)data
      forComponentWithID:(NSString*)tnUIID
{
  assert(tnUIID);
  [self writeJavascript:
      [NSString stringWithFormat:@"fireEvent('%@', %@)", 
          name, [data JSONString]]
      forComponentWithID:tnUIID];
}

+ (void)fireEvent:(NSString*)name 
         withData:(NSDictionary*)data
     forComponent:(id)component
{
  NSString* tnUIID = [self lookupIDForComponent:component];
  [self fireEvent:name withData:data forComponentWithID:tnUIID];
}

+ (void)fireEvent:(NSString*)name 
      withData:(NSDictionary*)data
      forComponentWithOptions:(NSDictionary*)options
{
  NSString* tnUIID = [options objectForKey:@"tnUIID"];
  [self fireEvent:name withData:data forComponentWithID:tnUIID];
}

+ (id)componentWithOptions:(NSDictionary*)options
{
  UIComponentPlugin* pluginForComponent = 
      [self pluginForComponentWithOptions:options];
  assert(pluginForComponent);
  id component = [[[pluginForComponent class] uiKitSubclass] alloc];
  component = [[pluginForComponent initComponent:component 
                                     withOptions:options] autorelease];
  [self registerComponent:component withOptions:options];
  [pluginForComponent setupComponent:component withOptions:options];
  
  return component;
}

- (id)initComponent:(id)component withOptions:(NSDictionary*)options
{
  return [component init];
}


- (void)setupComponent:(id)component
           withOptions:(NSDictionary*)options
{
}

- (id)getProperty:(NSString*)name
     forComponent:(id)component
{
  NSLog(@"Unknown property '%@'", name);
  assert(false);
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(id)component
{
  NSLog(@"Unknown property '%@'", name);
  assert(false);
}

- (void)setProperties:(NSArray*)propertyNames
         forComponent:(id)component
          fromOptions:(NSDictionary*)options
{
  [propertyNames enumerateObjectsUsingBlock:
      ^(id name, NSUInteger idx, BOOL *stop) {
        id value = [options objectForKey:name];
        if (value) {
          [self setProperty:name 
                  withValue:value 
               forComponent:component];
        }
      }];
}

- (void)getProperties:(NSMutableArray*)arguments
             withDict:(NSMutableDictionary*)options
{
  NSString* componentID = [options objectForKey:@"componentID"];
  assert(componentID);
  id component = [[self class] lookupComponentWithID:componentID];
  assert(component);

  NSMutableDictionary* propertyValues = 
      [[[NSMutableDictionary alloc] init] autorelease];
  NSArray* propertyNames = [options objectForKey:@"propertyNames"];
  assert(propertyNames && [propertyNames isKindOfClass:[NSArray class]]);
  [propertyNames 
      enumerateObjectsUsingBlock:^(id name, NSUInteger idx, BOOL *stop) {
        [propertyValues setObject:[self getProperty:name forComponent:component]
                           forKey:name];
      }];

  CDVPluginResult* result =
      [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                 messageAsDictionary:propertyValues];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}

- (void)setProperties:(NSMutableArray*)arguments
             withDict:(NSMutableDictionary*)options
{
  NSString* componentID = [options objectForKey:@"componentID"];
  assert(componentID);
  id component = [[self class] lookupComponentWithID:componentID];
  assert(component);

  NSDictionary* properties = [options objectForKey:@"properties"];
  [properties
      enumerateKeysAndObjectsUsingBlock:^(id name, id value, BOOL *stop) {
        [self setProperty:name withValue:value forComponent:component];
      }];

  CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}

- (void)noop:(NSMutableArray*)arguments
    withDict:(NSMutableDictionary*)options
{
  CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}
@end
