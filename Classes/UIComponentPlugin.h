@interface UIComponentPlugin : CDVPlugin {
 @private
}

+ (void)registerComponent:(id)component withID:(NSString*)tnUIID;
+ (void)registerComponent:(id)component withOptions:(NSDictionary*)options;
+ (void)unregisterComponent:(id)component;
+ (id)lookupComponentWithID:(NSString*)tnUIID;
+ (id)lookupComponentWithOptions:(NSDictionary*)options;
+ (NSString*)lookupIDForComponent:(id)component;

+ (id)pluginForComponentWithOptions:(NSDictionary*)options;

+ (NSString*)writeJavascript:(NSString*)javascript;
+ (id)writeJavascript:(NSString*)javascript
    forComponentWithID:(NSString*)tnUIID;
+ (id)writeJavascript:(NSString*)javascript
         forComponent:(id)component;

+ (void)fireEvent:(NSString*)name 
      withData:(NSDictionary*)data
      forComponentWithID:(NSString*)tnUIID;
+ (void)fireEvent:(NSString*)name 
         withData:(NSDictionary*)data
     forComponent:(id)component;
+ (void)fireEvent:(NSString*)name 
      withData:(NSDictionary*)data
      forComponentWithOptions:(NSDictionary*)options;

+ (Class)uiKitSubclass;
+ (void)subclassMethod:(SEL)selector
    withImplementation:(IMP)subclassedImplementation;
+ (IMP)getOriginalImplementation:(IMP)subclassedImplementation
                     forSelector:(SEL)selector
                         andSelf:(id)aSelf;

+ (id)componentWithOptions:(NSDictionary*)options;
- (id)initComponent:(id)component withOptions:(NSDictionary*)options;
- (void)setupComponent:(id)view withOptions:(NSDictionary*)options;

- (id)getProperty:(NSString*)name
     forComponent:(id)component;
- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(id)component;
- (void)setProperties:(NSArray*)propertyNames
         forComponent:(id)component
          fromOptions:(NSDictionary*)options;
@end
