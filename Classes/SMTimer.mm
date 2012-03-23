#import "SMTimer.h"

#import "jsapi.h"
#import "SMRuntime.h"

@implementation SMTimer

@synthesize callback = callback_;
@synthesize jsContext = jsContext_;
@synthesize timer = timer_;
@synthesize interval = interval_;
@synthesize repeats = repeats_;

+ (id)registeredTimerWithCallback:(jsval)callback
                        jsContext:(JSContext*)jsContext
                         interval:(NSTimeInterval)interval
                          repeats:(BOOL)repeats
{
  SMTimer* timer = [[[SMTimer alloc] initWithCallback:callback
                                            jsContext:jsContext
                                             interval:interval
                                              repeats:repeats] autorelease];

  [timer register];

  return timer;
}

- (void)dealloc
{
  JS_BeginRequest(jsContext_);
  JS_RemoveRoot(jsContext_, &callback_);
  JS_EndRequest(jsContext_);

  self.timer = nil;
  [super dealloc];
}

- (id)initWithCallback:(jsval)callback
             jsContext:(JSContext*)jsContext
              interval:(NSTimeInterval)interval
               repeats:(BOOL)repeats
{
  if ((self = [super init])) {
    assert(jsContext);
    assert(interval >= 0);

    self.callback = callback;
    JS_AddRoot(jsContext, &callback_);

    self.jsContext = jsContext;
    self.interval = interval;
    self.repeats = repeats;
  }
  return self;
}

- (void)fire:(NSTimer*)nsTimer
{
  JS_BeginRequest(jsContext_);

  jsval retVal;
  if (JS_CallFunctionValue(jsContext_, NULL, callback_, NULL, NULL, &retVal)
      == JS_FALSE) {
    reportException(jsContext_);
  }

  JS_EndRequest(jsContext_);
}

- (void)register
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval_
                                                  target:self
                                                selector:@selector(fire:)
                                                userInfo:nil
                                                 repeats:repeats_];
}

- (void)unregister
{
  JS_RemoveRoot(jsContext_, &callback_);
  [timer_ invalidate];
}

@end
