#import "jsapi.h"

@interface SMTimer : NSObject {
 @private
  jsval callback_;
  JSContext* jsContext_;
  NSTimer* timer_;
  NSTimeInterval interval_;
  BOOL repeats_;
}

@property (nonatomic, assign) jsval callback;
@property (nonatomic, assign) JSContext* jsContext;
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, assign) BOOL repeats;

+ (id)registeredTimerWithCallback:(jsval)callback
                        jsContext:(JSContext*)jsContext
                         interval:(NSTimeInterval)interval
                          repeats:(BOOL)repeats;

- (id)initWithCallback:(jsval)callback
             jsContext:(JSContext*)jsContext
              interval:(NSTimeInterval)interval
               repeats:(BOOL)repeats;

- (void)register;
- (void)unregister;

@end
