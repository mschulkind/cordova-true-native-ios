# Cool Stuff

## SpiderMonkey

The javascript engine behind firefox, SpiderMonkey, can be used for the
javascript engine instead of *UIWebView*. Using SpiderMonkey as the engine
allows us to access internal interfaces of the javascript engine, leading to
many of the improvements mentioned below.  SpiderMonkey support is provided by
[iMonkey](https://github.com/couchbaselabs/iMonkey) which is maintained by
Couchbase Labs.

The original motiviation for this was due to a memory leak I believe was
occuring inside the UIWebView, but was fixed through migrating to SpiderMonkey.

Since SpiderMonkey gives us direct access to the javascript engine, we can implement a more efficient and predictable bridge design.

We also get more accurate stack traces:
```
```

## UIWebView Debug Delegate

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
