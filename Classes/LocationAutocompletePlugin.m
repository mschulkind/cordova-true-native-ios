#import "LocationAutocompletePlugin.h"

#import "QSStrings.h"

@implementation LocationAutocompletePlugin

@synthesize trie = trie_;

- (void)onMemoryWarning
{
  self.trie = nil;
}

static NSString* transformForCompletion(NSString* str) {
  // Lowercase and strip out all spaces, commas, and periods. Uses C strings
  // for speed.
  const char* cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
  int strLength = [str length];
  char* transformedCStr = malloc(strLength);
  int transformedLength = 0;
  assert(transformedCStr);
  for (int i = 0; i < strlen(cStr); ++i) {
    char c = cStr[i];

    if (c == '.' || c == ',' || c == ' ') {
      continue;
    }

    transformedCStr[transformedLength] = tolower(c);
    transformedLength++;
  }
  transformedCStr[transformedLength] = 0;

  NSString* transformedStr =
      [NSString stringWithCString:transformedCStr 
                         encoding:NSASCIIStringEncoding];
  free(transformedCStr);

  return transformedStr;
}

#include "EncodedCitiesUS.h"
- (NDMutableTrie*)trie {
  if (!trie_) {
    NSData* citiesData = [QSStrings decodeBase64WithString:encodedCitiesUS];
    NSString* citiesJSON = 
      [[[NSString alloc] 
          initWithData:citiesData encoding:NSUTF8StringEncoding] autorelease];
    NSArray* cities = [citiesJSON objectFromJSONString];

    self.trie = [NDMutableTrie trie];
    for (NSString* city in cities) {
      [trie_ setObject:city forKey:transformForCompletion(city)];
    }
  }

  return trie_;
}

- (void)completionsFor:(NSMutableArray*)arguments
              withDict:(NSMutableDictionary*)options
{
  NSString* prefix = [options objectForKey:@"prefix"];
  assert(prefix);
  prefix = transformForCompletion(prefix);
  NSNumber* limitNumber = [options objectForKey:@"limit"];
  int limit = [limitNumber intValue];

  __block int completionsCount = 0;
  NSArray* completions = 
      [self.trie everyObjectForKeyWithPrefix:prefix passingTest:
      ^BOOL (id object, BOOL *stop) {
        completionsCount++;
        if (completionsCount >= limit) {
          *stop = YES;
        }

        return completionsCount <= limit;
      }];

  CDVPluginResult* result =
      [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                     messageAsArray:completions];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}

@end
