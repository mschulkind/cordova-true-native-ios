#import "UIWebViewScriptDebugDelegate.h"

#ifndef NDEBUG

@class WebFrame;

@interface WebView
  - (void)setScriptDebugDelegate:(id)delegate;
@end

@interface WebScriptCallFrame
  - (id)exception;
  - (NSString*)functionName;
  - (WebScriptCallFrame*)caller;
@end

@interface WebScriptObject
  - (id)valueForKey:(NSString*)key;
@end

@implementation UIWebView (DebugCategory)

- (void)webView:(id)sender 
  didClearWindowObject:(id)windowObject 
              forFrame:(WebFrame*)frame {
  [sender setScriptDebugDelegate:[[UIWebViewScriptDebugDelegate alloc] init]];
}

@end

@implementation UIWebViewScriptDebugDelegate

@synthesize sourceIDMap = sourceIDMap_;
static NSString* const kSourceIDMapFilenameKey = @"filename";
static NSString* const kSourceIDMapSourceKey = @"source";
static NSString* const kSourceIDMapBaseLineNumberKey = @"baselinenumber";


- (id)init
{
  if ((self = [super init])) {
    self.sourceIDMap = [NSMutableDictionary dictionary];
  }

  return self;
}

+ (NSString*)filenameForURL:(NSURL*)url
{
  NSString* pathString = [url path];
  NSArray* pathComponents = [pathString pathComponents];
  return [pathComponents objectAtIndex:([pathComponents count] - 1)];
}

+ (NSString*)formatSource:(NSString*)source
{
  NSMutableString* formattedSource = [NSMutableString stringWithCapacity:100];
  [formattedSource appendString:@"Source:\n"];
  int* lineNumber = malloc(sizeof(int));
  *lineNumber = 1;
  [source enumerateLinesUsingBlock:^(NSString* line, BOOL* stop) {
    [formattedSource appendFormat:@"%3d: %@", *lineNumber, line];
    (*lineNumber)++;
  }];
  free(lineNumber);
  [formattedSource appendString:@"\n\n"];

  return formattedSource;
}

- (void) webView:(WebView*)webView
  didParseSource:(NSString*)source
  baseLineNumber:(unsigned int)baseLineNumber
         fromURL:(NSURL*)url
        sourceId:(int)sourceID
     forWebFrame:(WebFrame*)webFrame
{
  NSString* filename = nil;
  if (url) {
    filename = [UIWebViewScriptDebugDelegate filenameForURL:url];
  }

  // Save the sourceID -> source and filename mapping for identifying
  // exceptions later.
  NSMutableDictionary* mapEntry = 
      [NSMutableDictionary 
          dictionaryWithObjectsAndKeys:
          source, kSourceIDMapSourceKey, 
          [NSNumber numberWithInt:baseLineNumber], 
          kSourceIDMapBaseLineNumberKey, nil];
  if (filename) {
    [mapEntry setObject:filename forKey:kSourceIDMapFilenameKey];
  }
  [self.sourceIDMap setObject:mapEntry
                       forKey:[NSNumber numberWithInt:sourceID]];
  //NSLog(@"%@", [source substringToIndex:MIN(300, [source length])]);
}


- (void)webView:(WebView *)webView
    failedToParseSource:(NSString *)source
    baseLineNumber:(unsigned int)baseLineNumber
    fromURL:(NSURL *)url
    withError:(NSError *)error
    forWebFrame:(WebFrame *)webFrame
{
  NSDictionary* userInfo = [error userInfo];
  NSNumber* fileLineNumber =
      [userInfo objectForKey:@"WebScriptErrorLineNumber"];

  NSString* filename = @"";
  NSMutableString* sourceLog = [NSMutableString stringWithCapacity:100];
  if (url) {
    filename = 
        [NSString stringWithFormat:@"filename: %@, ",
            [UIWebViewScriptDebugDelegate filenameForURL:url]];
  } else {
    [sourceLog appendString:[[self class] formatSource:source]];
  }
  NSLog(
      @"Parse error - %@baseLineNumber: %d, fileLineNumber: %@\n%@",
      filename, baseLineNumber, fileLineNumber, sourceLog);

  assert(false);
}

- (void)webView:(WebView *)webView
    exceptionWasRaised:(WebScriptCallFrame *)frame
    sourceId:(int)sourceID
    line:(int)lineNumber
    forWebFrame:(WebFrame *)webFrame
{
  // Lookup the sourceID and pull out the fields.
  NSDictionary* sourceLookup = 
      [self.sourceIDMap objectForKey:[NSNumber numberWithInt:sourceID]];
  assert(sourceLookup);
  NSString* filename = [sourceLookup objectForKey:kSourceIDMapFilenameKey];
  NSString* source = [sourceLookup objectForKey:kSourceIDMapSourceKey];
  unsigned int baseLineNumber = 
      [[sourceLookup objectForKey:kSourceIDMapBaseLineNumberKey] intValue];

  NSMutableString *message = [NSMutableString stringWithCapacity:100];

  [message appendString:@"Exception - "];

  WebScriptObject* exception = [frame exception];

  @try {
    [message appendFormat:@"name: %@, ", [exception valueForKey:@"name"]];
  } @catch (NSException* e) {
  }

  [message appendFormat:@"sourceID: %d", sourceID];

  if (filename) {
    [message appendFormat:@", filename: %@", filename];
  }

  @try {
    [message appendFormat:@"\nMessage: %@\n\n", 
        [exception valueForKey:@"message"]];
  } @catch (NSException* e) {
  }

  if (!filename) {
    [message appendString:[[self class] formatSource:source]];
  }

  [message appendString:@"Offending line:\n"];
  NSArray* sourceLines = [source componentsSeparatedByString:@"\n"];
  NSString* sourceLine = 
      [sourceLines objectAtIndex:(lineNumber - baseLineNumber)];
  if ([sourceLine length] > 200) {
    sourceLine = [sourceLine substringToIndex:200];
    sourceLine = [NSString stringWithFormat:@"%@...", sourceLine];
  }
  [message appendFormat:@"  %d: %@\n\n", lineNumber, sourceLine];

  NSLog(@"%@", message);
}

@end

#endif
