struct JSRuntime;
struct JSContext;
struct JSObject;

void reportException(struct JSContext* cx);

@interface SMRuntime : NSObject {
 @private
  struct JSRuntime* jsRuntime_;
  struct JSContext* jsContext_;
  struct JSObject* jsGlobalObject_;
}

- (id)initWithSourceFiles:(NSArray*)sourceFiles;
- (void)loadJavascriptFile:(NSString*)filename;
- (NSString*)writeJavascript:(NSString*)javascript;
- (void)runGC;

@end
