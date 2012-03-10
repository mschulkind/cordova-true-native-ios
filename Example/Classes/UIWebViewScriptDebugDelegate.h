@interface UIWebViewScriptDebugDelegate : NSObject {
 @private
  NSMutableDictionary* sourceIDMap_;
}

@property (nonatomic, retain) NSMutableDictionary* sourceIDMap;

@end
