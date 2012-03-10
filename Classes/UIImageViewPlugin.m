#import "UIImageViewPlugin.h"

#import "EGOImageView.h"

@interface TNUIImageView : EGOImageView {
 @private
}

@end

@implementation TNUIImageView

@end

@implementation UIImageViewPlugin

+ (Class)uiKitSubclass 
{
  return [TNUIImageView class];
}

- (void)setupComponent:(TNUIImageView*)imageView 
           withOptions:(NSDictionary*)options
{
  [super setupComponent:imageView withOptions:options];

  [self setProperties:
      [NSArray arrayWithObjects:@"imagePath", @"imageURL", nil]
      forComponent:imageView
      fromOptions:options];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUIImageView*)imageView
{
  if (false) {
  } else {
    return [super getProperty:name forComponent:imageView];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUIImageView*)imageView
{
  if ([name isEqual:@"imagePath"]) {
    if (value && ![value isEqual:@""]) {
      imageView.image = [UIImage imageNamed:value];
      assert(imageView.image);
    } else {
      imageView.image = nil;
    }
  } else if ([name isEqual:@"imageURL"]) {
    imageView.imageURL = [NSURL URLWithString:value];
  } else {
    [super setProperty:name withValue:value forComponent:imageView];
  }
}

- (void)getImageSize:(NSMutableArray*)arguments
            withDict:(NSMutableDictionary*)options
{
  NSString* imagePath = [options objectForKey:@"imagePath"];
  assert(imagePath);

  UIImage* image = [UIImage imageNamed:imagePath];
  assert(image);

  NSDictionary* sizeDict = 
      [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithFloat:image.size.width], @"width",
          [NSNumber numberWithFloat:image.size.height], @"height",
          nil];

  CDVPluginResult* result =
      [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                 messageAsDictionary:sizeDict];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}

@end
