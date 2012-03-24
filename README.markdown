# Cool Stuff Inside

## Screen Shots

![screenshot](raw/master/screenshots/screenshot1.png)
![screenshot](raw/master/screenshots/screenshot2.png)
![screenshot](raw/master/screenshots/screenshot3.png)
![screenshot](raw/master/screenshots/screenshot4.png)
![screenshot](raw/master/screenshots/screenshot5.png)

## Real Native Controls

True Native gives you access directly to the iOS native controls. If you
choose, you can display parts of a UIWebView along with native controls, but
True Native allows you to create a full app without ever using or displaying a
UIWebView. Most iOS views/controls are already supported, and support for those
that aren't should be easy to add.

## Javascript Engine Choices

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
[UIWebViewScriptDebugDelegate](blob/master/Example/Classes/UIWebViewScriptDebugDelegate.m)
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

All of the javascript is written in (CoffeeScript)[http://coffeescript.org/].
(SCons)[http://www.scons.org/] is used as an external build tool to
automatically compile the CoffeeScript to javascript as part of the XCode build
process.

## Baked In Javascript

Instead of requiring the user to include the plugins' javascript manually into
their project, only one exec call is required at the beginning of the app's
javascript execution to load the required javascript:

```coffee
window.onDeviceReady = ->
  Cordova.exec(
    onTNReady, null, 'cordovatruenative.component', 'loadJavascript', [])

onTNReady = ->
  # Program starts here.

```

To accomplish this, SCons is used to base64 encode the javascript source and
write out an Objective-C source file with a single string containing the
base64-encoded javascript. Upon calling `loadJavascript`, the javascript is
decoded and injected.

## Other notable features

* **Facebook support** This support is not complete, but allows for login using
  the (Facebook SDK for iOS)[https://github.com/facebook/facebook-ios-sdk].

* **US City autocomplete** This (ruby
  script)[blob/master/scripts/generate\_cities\_map.rb] generates a JSON map of
  all US city names to their lat/long. The source data is a set of zipcodes
  with lat/long, so each city's lat/long is the mean of all its component
  zipcodes. This JSON is base64 encoded and linked in as well. The location
  autocomplete plugin loads the data into a
  (Trie)[https://github.com/mschulkind/ndtrie] and serves up completions. The
  Instagram demo in the Example app makes use of this.

* **GridCell layout** To help the layout of the controls and views, a GridCell
  layout engine is provide. See the example app and (source
  code)[blob/master/CoffeeScripts/grid\_cell\_control.coffee] for more details.

* **Android support** Full android support is planned as the next major
  feature, but it work has not yet begun. The iOS version has been designed
  with android support in mind.

# Example App

The example app has been submitted to the app store for review. I will post a
link here once it is published. You can also build the app yourself:

## Prerequesites

1. scons
2. coffee (coffee-script compiler)
3. Cordova 1.5.0

The easiest way to get the prerequesites is to install
[Homebrew](http://mxcl.github.com/homebrew/) and then run the command `brew
install scons coffee-script`.

## How to Build and Run

1. After any clone or pull (including the first time): `git submodule update
   --init --recursive`
2. Open `Example/Example.xcodeproj`.
3. Select the `Example [iMonkey] > iPhone Simulator` target. The target called
   `Example` uses the UIWebView and the target called `Example iMonkey` uses
   SpiderMonkey.
4. Hit play/run.

# How to Run the Tests

There aren't enough tests yet, but there are at least a few. Directions for how
to run them are coming.

# How to Create Your Own App

Directions coming. For now, copying the example app is a great start.
