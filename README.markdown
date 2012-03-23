# Cool Stuff

## Javascript Engine Choice

By choosing either the `Example` target or the `Example iMonkey` target, you
can switch between using a UIWebView for javascript or SpiderMonkey (referred
to throughout as SM), the javascript engine behind FireFox. SpiderMonkey
support is provided by [iMonkey](https://github.com/couchbaselabs/iMonkey)
which is maintained by [Couchbase Labs](https://github.com/couchbaselabs).

## SpiderMonkey Improvements

Using SpiderMonkey as the engine allows us to access internal interfaces of the
javascript engine. This increased control is directly responsible for the
following improvements:

* **Memory Usage** The original motiviation for SpiderMonkey support was due to
  a memory leak I believe was occuring inside the UIWebView, but was fixed
  through migrating to SpiderMonkey. My hypothesis is that UIWebViews don't run
  their GC immediately upon receiving a memory warning. Because we can now
  manually invoke the GC for SM, we have control and can ensure this happens.

* **Bridge Design** The javascript<->ObjC bridge has been greatly simplified due
  to being able to provide the javascript environment with methods that
  directly return values from the ObjC side. The performance has not been tuned
  or compared yet, but I suspect it is already better than a UIWebView. There
  are many avenues left for future improvement as well.

* **Stack Traces** When exceptions happen, we get more accurate and detailed
  stack traces:

```
2012-03-23 19:25:31.707 True Native[39107:17003] twitter_demo.js:96:TypeError: imageAndTextCell.someMissingMethod is not a function
2012-03-23 19:25:31.708 True Native[39107:17003] Stack trace:
([object Object],[object Object])@twitter_demo.js:96
(-1,0,"18","construct")@writeJavascript:2067
(-1,0,"18")@writeJavascript:2071
@writeJavascript:1
Assertion failed: (false), function reportException, file /tmp/cordova-true-native/Classes/SMRuntime.mm, line 181.
```

You may notice two frames with a filename of `writeJavascript`. Frames like
this can come from any `writeJavascript` call, but these particular ones are
from the baked in javascript which is injected using `writeJavascript`. You can
recognize these lines, in part, due to their high line number. You can find the
javascript source in `build/all.js` after building the example..

## UIWebView Debug Delegate

Through non-public interfaces, it's possible to report any exceptions that
occur inside of a UIWebView. The exception detail is not as great as with
SpiderMonkey, but it's better than nothing. The code is automatically excluded
from non-DEBUG builds since it is not allowed on the app store (due to the use
of the private interfaces). See the
[UIWebViewScriptDebugDelegate](https://github.com/mschulkind/cordova-true-native-ios/blob/master/Example/Classes/UIWebViewScriptDebugDelegate.m)
for more details.

Here is an example stack trace. This is the same exception as shown above:

```
2012-03-23 19:27:47.205 True Native[39323:17003] Exception - name: TypeError, sourceID: 148501056, value: <WebScriptObject: 0x8bbdc00>, filename: twitter_demo.js, 
Message: 'undefined' is not a function



Offending line:
  49:           constructCallback: function(rowEntry, row) {
```

As you can see, this is not so satisfying. It may be possible to make this more
accurate, but I have not yet found a way, since nothing about this interface is
documented.

## CoffeeScript

## Baked In Javascript

# Prerequesites

1. scons
2. coffee (coffee-script compiler)
3. Cordova 1.5.0

The easiest way to get the prerequesites is to install
[Homebrew](http://mxcl.github.com/homebrew/) and then run the command `brew
install scons coffee-script`.

# How to Run the Example

1. `git submodule update --init --recursive`
2. Open `Example/Example.xcodeproj`
3. Select the `Example > iPhone Simulator` target
4. Hit play/run.
