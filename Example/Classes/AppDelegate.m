/*
   Licensed to the Apache Software Foundation (ASF) under one
   or more contributor license agreements.  See the NOTICE file
   distributed with this work for additional information
   regarding copyright ownership.  The ASF licenses this file
   to you under the Apache License, Version 2.0 (the
   "License"); you may not use this file except in compliance
   with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
*/

//
//  AppDelegate.m
//  Example
//
//  Created by Matthew Schulkind on 2/26/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

#ifdef CORDOVA_FRAMEWORK
	#import <Cordova/CDV.h>
#else
	#import "CDV.h"
#endif

@implementation AppDelegate

@synthesize window, viewController;

- (id) init
{	
  NSHTTPCookieStorage *cookieStorage = 
      [NSHTTPCookieStorage sharedHTTPCookieStorage]; 
  [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

  [CDVURLProtocol registerPGHttpURLProtocol];

  return [super init];
}

#pragma UIApplicationDelegate implementation

/**
 * This is main kick off after the app inits, the views and Settings are setup
 * here. (preferred - iOS4 and up)
 */
- (BOOL) application:(UIApplication*)application 
  didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{    
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
  self.window.autoresizesSubviews = YES;

  CGRect viewBounds = [[UIScreen mainScreen] applicationFrame];

  self.viewController = [[[MainViewController alloc] init] autorelease];
  self.viewController.useSplashScreen = YES;
  self.viewController.wwwFolderName = @"www";
  self.viewController.startPage = @"index.html";
  self.viewController.view.frame = viewBounds;

  // over-ride delegates
  self.viewController.webView.delegate = self;
  self.viewController.commandDelegate = self;

  [self.window addSubview:self.viewController.view];
  [self.window makeKeyAndVisible];

  return YES;
}

#pragma CDVCommandDelegate implementation

- (id) getCommandInstance:(NSString*)className
{
  return [self.viewController getCommandInstance:className];
}

- (BOOL) execute:(CDVInvokedUrlCommand*)command
{
  return [self.viewController execute:command];
}

- (NSString*) pathForResource:(NSString*)resourcepath;
{
  return [self.viewController pathForResource:resourcepath];
}

#pragma UIWebDelegate implementation

- (void) webViewDidFinishLoad:(UIWebView*) theWebView 
{
  // Black base color for background matches the native apps
  theWebView.backgroundColor = [UIColor blackColor];

  return [self.viewController webViewDidFinishLoad:theWebView];
}

- (void) webViewDidStartLoad:(UIWebView*)theWebView 
{
  return [self.viewController webViewDidStartLoad:theWebView];
}

- (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error 
{
  return [self.viewController webView:theWebView didFailLoadWithError:error];
}

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
  return [self.viewController webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void) dealloc
{
  [super dealloc];
}

@end
