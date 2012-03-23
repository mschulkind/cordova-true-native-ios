#import "SMRuntime.h"

#import "jsapi.h"
#import "SMTimer.h"
#import "QSStrings.h"

static NSString* stringWithJsval(JSContext* jsContext, jsval stringJsval)
{
  JSString* jsString = JS_ValueToString(jsContext, stringJsval);
  return [NSString stringWithCharacters:JS_GetStringChars(jsString)
                                 length:JS_GetStringLength(jsString)];
}

static JSBool jsLog(
    JSContext* cx, JSObject* obj, uintN argc, jsval *argv, jsval *rval)
{
  assert(argc == 1);

  NSLog(@"%@", stringWithJsval(cx, argv[0]));

  JS_SET_RVAL(cx, rval, JSVAL_VOID);
  return JS_TRUE;
}

@interface AppDelegate
- (void)execute:(CDVInvokedUrlCommand*)command;
@end

static JSBool jsNativeExec(
    JSContext* cx, JSObject* obj, uintN argc, jsval *argv, jsval *rval)
{
  assert(argc == 1);
  NSString* commandJSON = stringWithJsval(cx, argv[0]);

  NSDictionary* commandObject = [commandJSON objectFromJSONString];
  assert([commandObject isKindOfClass:[NSDictionary class]]);

	[(AppDelegate*)[[UIApplication sharedApplication] delegate]
      execute:[CDVInvokedUrlCommand commandFromObject:commandObject]];

  JS_SET_RVAL(cx, rval, JSVAL_VOID);
  return JS_TRUE;
}

static JSClass jsTimerIDClass = {
    "TimerID", JSCLASS_HAS_PRIVATE,
    JS_PropertyStub, JS_PropertyStub, JS_PropertyStub, JS_PropertyStub,
    JS_EnumerateStub, JS_ResolveStub, JS_ConvertStub, JS_FinalizeStub,
    JSCLASS_NO_OPTIONAL_MEMBERS
};

static JSBool jsSetTimer(
    JSContext* cx, JSObject* obj, uintN argc, jsval *argv, jsval *rval,
    BOOL repeats)
{
  assert(argc == 2);
  jsval callbackJsval = argv[0];
  assert(JSVAL_IS_OBJECT(callbackJsval));

  jsval intervalJsval = argv[1];
  int intervalMsecs;
  assert(JS_ValueToInt32(cx, intervalJsval, &intervalMsecs) == JS_TRUE);
  assert(intervalMsecs >= 0);

  SMTimer* timer = 
      [SMTimer registeredTimerWithCallback:callbackJsval
                                 jsContext:cx
                                  interval:intervalMsecs / 1000.0
                                   repeats:repeats];

  JSObject* timerID = JS_NewObject(cx, &jsTimerIDClass, NULL, NULL);
  JS_SetPrivate(cx, timerID, timer);

  JS_SET_RVAL(cx, rval, OBJECT_TO_JSVAL(timerID));
  return JS_TRUE;
}

static JSBool jsSetTimeout(
    JSContext* cx, JSObject* obj, uintN argc, jsval *argv, jsval *rval)
{
  return jsSetTimer(cx, obj, argc, argv, rval, NO);
}

static JSBool jsSetInterval(
    JSContext* cx, JSObject* obj, uintN argc, jsval *argv, jsval *rval)
{
  return jsSetTimer(cx, obj, argc, argv, rval, YES);
}

static JSBool jsClearTimer(
    JSContext* cx, JSObject* obj, uintN argc, jsval *argv, jsval *rval)
{
  assert(argc == 1);
  jsval timerIDJsval = argv[0];
  if (JSVAL_IS_OBJECT(timerIDJsval) && !JSVAL_IS_NULL(timerIDJsval)) {
    JSObject* timerID = JSVAL_TO_OBJECT(timerIDJsval);

    SMTimer* timer = 
        (SMTimer*)JS_GetInstancePrivate(cx, timerID, &jsTimerIDClass, NULL);
    assert(timer);

    [timer unregister];
  }

  JS_SET_RVAL(cx, rval, JSVAL_VOID);
  return JS_TRUE;
}

static JSBool jsSetItem(
    JSContext* cx, JSObject* obj, uintN argc, jsval *argv, jsval *rval)
{
  assert(argc == 2);
  NSString* key = stringWithJsval(cx, argv[0]);
  jsval valueJsval = argv[1];

  [[NSUserDefaults standardUserDefaults] 
      setObject:stringWithJsval(cx, valueJsval)
         forKey:key];

  JS_SET_RVAL(cx, rval, JSVAL_VOID);
  return JS_TRUE;
}

static JSBool jsRemoveItem(
    JSContext* cx, JSObject* obj, uintN argc, jsval *argv, jsval *rval)
{
  assert(argc == 1);
  NSString* key = stringWithJsval(cx, argv[0]);

  [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];

  JS_SET_RVAL(cx, rval, JSVAL_VOID);
  return JS_TRUE;
}

static JSBool jsGetItem(
    JSContext* cx, JSObject* obj, uintN argc, jsval *argv, jsval *rval)
{
  assert(argc == 1);
  NSString* key = stringWithJsval(cx, argv[0]);

  NSString* value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
  if (value) {
    jsval valueJsval =
        STRING_TO_JSVAL(
            JS_NewUCStringCopyZ(
                cx, 
                (jschar*)[value cStringUsingEncoding:
                    NSUnicodeStringEncoding]));
    JS_SET_RVAL(cx, rval, valueJsval);
  } else {
    JS_SET_RVAL(cx, rval, JSVAL_VOID);
  }
  return JS_TRUE;
}

static void reportError(
    JSContext* cx, const char* message, JSErrorReport* report)
{
  NSLog(
      @"%s:%u:%s\n",
      report->filename ? report->filename : "<no filename>",
      (unsigned int) report->lineno, message);
}

void reportException(JSContext* cx) {
  if (JS_IsExceptionPending(cx) == JS_TRUE) {
    jsval exception;
    assert(JS_GetPendingException(cx, &exception) == JS_TRUE);
    JS_ReportPendingException(cx);

    JSObject* exceptionObject;
    assert(JS_ValueToObject(cx, exception, &exceptionObject) == JS_TRUE);
    jsval stack;
    assert(JS_GetProperty(cx, exceptionObject, "stack", &stack) == JS_TRUE);
    NSLog(@"Stack trace:\n%@", stringWithJsval(cx, stack));
  } else {
    assert(false);
  }

  assert(false);
}

@implementation SMRuntime

static JSClass jsGlobalClass = {
    "global", JSCLASS_GLOBAL_FLAGS,
    JS_PropertyStub, JS_PropertyStub, JS_PropertyStub, JS_PropertyStub,
    JS_EnumerateStub, JS_ResolveStub, JS_ConvertStub, JS_FinalizeStub,
    JSCLASS_NO_OPTIONAL_MEMBERS
};

#import "EncodedJavascriptImonkey.h"
- (void)loadBuiltinJavascript
{
  NSData* sourceData = 
      [QSStrings decodeBase64WithString:encodedJavascriptImonkey];
  NSString* source = 
      [[[NSString alloc] 
          initWithData:sourceData encoding:NSUTF8StringEncoding] autorelease];
  [self writeJavascript:source];
}

// See here for more info:
// https://developer.mozilla.org/En/SpiderMonkey/JSAPI_User_Guide
- (void)setupSpiderMonkeyWithSourceFiles:(NSArray*)sourceFiles
{
  NSLog(@"Starting setting up SpiderMonkey");

  jsRuntime_ = JS_NewRuntime(64L * 1024L * 1024L);
  assert(jsRuntime_);

  // Create a context. 
  jsContext_ = JS_NewContext(jsRuntime_, 8192);
  assert(jsContext_);

  JS_SetOptions(
      jsContext_, 
      //JS_GetOptions(jsContext_)
      JSOPTION_VAROBJFIX | JSOPTION_COMPILE_N_GO 
      | JSOPTION_DONT_REPORT_UNCAUGHT);
      //| JSVERSION_LATEST);
  JS_SetVersion(jsContext_, JSVERSION_LATEST);
  //JS_ToggleOptions(jsContext_, JSOPTION_XML);
  JS_SetErrorReporter(jsContext_, reportError);

  JS_BeginRequest(jsContext_);

  // Create the global object.
  jsGlobalObject_ = JS_NewObject(jsContext_, &jsGlobalClass, NULL, NULL);
  assert(jsGlobalObject_);
  JS_SetGlobalObject(jsContext_, jsGlobalObject_);

  // Populate the global object with the standard globals, like object and
  // array. 
  assert(JS_InitStandardClasses(jsContext_, jsGlobalObject_));

  // Point 'window' right back at the global object.
  JS_DefineProperty(
      jsContext_, jsGlobalObject_, "window", OBJECT_TO_JSVAL(jsGlobalObject_), 
      NULL, NULL, 0);

  // Add some global functions.
  JS_DefineFunction(
      jsContext_, jsGlobalObject_, "nativeExec", jsNativeExec, 1, 0);
  JS_DefineFunction(
      jsContext_, jsGlobalObject_, "setTimeout", jsSetTimeout, 2, 0);
  JS_DefineFunction(
      jsContext_, jsGlobalObject_, "clearTimeout", jsClearTimer, 1, 0);
  JS_DefineFunction(
      jsContext_, jsGlobalObject_, "setInterval", jsSetInterval, 2, 0);
  JS_DefineFunction(
      jsContext_, jsGlobalObject_, "clearInterval", jsClearTimer, 1, 0);

  // Create the console object with log and error functions.
  JSObject* consoleObject = JS_NewObject(jsContext_, NULL, NULL, NULL);
  JS_DefineProperty(
      jsContext_, jsGlobalObject_, "console", OBJECT_TO_JSVAL(consoleObject),
      NULL, NULL, 0);
  JS_DefineFunction(jsContext_, consoleObject, "log", jsLog, 1, 0);
  JS_DefineFunction(jsContext_, consoleObject, "error", jsLog, 1, 0);

  // Create the localStorage object with setItem and getItem functions.
  JSObject* localStorageObject = JS_NewObject(jsContext_, NULL, NULL, NULL);
  JS_DefineProperty(
      jsContext_, jsGlobalObject_, "localStorage", 
      OBJECT_TO_JSVAL(localStorageObject), NULL, NULL, 0);
  JS_DefineFunction(
      jsContext_, localStorageObject, "getItem", jsGetItem, 1, 0);
  JS_DefineFunction(
      jsContext_, localStorageObject, "setItem", jsSetItem, 2, 0);
  JS_DefineFunction(
      jsContext_, localStorageObject, "removeItem", jsRemoveItem, 1, 0);

  // Create the document object.
  JSObject* documentObject = JS_NewObject(jsContext_, NULL, NULL, NULL);
  JS_DefineProperty(
      jsContext_, jsGlobalObject_, "document", OBJECT_TO_JSVAL(documentObject),
      NULL, NULL, 0);

  [self loadBuiltinJavascript];

  if (sourceFiles) {
    for (NSString* sourceFile in sourceFiles) {
      [self loadJavascriptFile:sourceFile];
    }
  }

  // Set the document readyState to 'loaded'.
  JS_DefineProperty(
      jsContext_, documentObject, "readyState",
      STRING_TO_JSVAL(JS_NewStringCopyZ(jsContext_, "loaded")), NULL, NULL, 0);

  JS_EndRequest(jsContext_);

  NSLog(@"Done setting up SpiderMonkey");
}

- (id)initWithSourceFiles:(NSArray*)sourceFiles
{
  if ((self = [super init])) {
    [self setupSpiderMonkeyWithSourceFiles:sourceFiles];
  }
  return self;
}

- (void)dealloc
{
  JS_DestroyContext(jsContext_);
  JS_DestroyRuntime(jsRuntime_);
  JS_ShutDown();
  [super dealloc];
}

- (void)loadJavascriptFile:(NSString*)filename
{
  NSLog(@"Loading %@", filename);

  NSString* filePath =
      [[NSBundle mainBundle] pathForResource:
          [NSString stringWithFormat:@"www/%@", filename] ofType:nil];  
  NSData *jsData = [NSData dataWithContentsOfFile:filePath];  
  assert(jsData);

  JSBool success = JS_EvaluateScript(
      jsContext_, jsGlobalObject_, (const char*)[jsData bytes],
      [jsData length], 
      [filename cStringUsingEncoding:NSASCIIStringEncoding], 1, NULL);
  if (success == JS_FALSE) {
    reportException(jsContext_);
  }
}

- (void)loadSourceFiles:(NSArray*)sourceFiles
{
  JS_BeginRequest(jsContext_);

  for (NSString* sourceFile in sourceFiles) {
    [self loadJavascriptFile:sourceFile];
  }

  JS_EndRequest(jsContext_);
}

- (NSString*)writeJavascript:(NSString*)javascript
{
  JS_BeginRequest(jsContext_);

  jsval retVal;
  JSBool success = JS_EvaluateUCScript(
      jsContext_, jsGlobalObject_, 
      (jschar*)[javascript cStringUsingEncoding:NSUnicodeStringEncoding],
      [javascript length], "writeJavascript", 1, &retVal);
  if (success == JS_FALSE) {
    reportException(jsContext_);
  }

  NSString* resultString = stringWithJsval(jsContext_, retVal);

  JS_EndRequest(jsContext_);

  return resultString;
}

- (void)runGC
{
  JS_GC(jsContext_);
}

@end
