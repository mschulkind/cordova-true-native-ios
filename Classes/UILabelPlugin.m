#import "UILabelPlugin.h"

#import "UIUtil.h"

@interface TNUILabel : UILabel {
}
@end

@implementation TNUILabel

@end

@implementation UILabelPlugin

+ (Class)uiKitSubclass 
{
  return [TNUILabel class];
}

- (void)setupComponent:(TNUILabel*)label withOptions:(NSDictionary*)options
{
  [super setupComponent:label withOptions:options];

  label.font = [UIUtil fontFromOptions:options];

  [self setProperties:
      [NSArray arrayWithObjects:
          @"text", @"color", @"align", @"maxNumberOfLines", nil]
      forComponent:label
      fromOptions:options];
}
- (id)getProperty:(NSString*)name
     forComponent:(TNUILabel*)label
{
  if (false) {
  } else {
    return [super getProperty:name forComponent:label];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUILabel*)label
{
  if ([name isEqual:@"text"]) {
    label.text = value;
  } else if ([name isEqual:@"color"]) {
    label.textColor = [UIUtil colorFromString:value];
  } else if ([name isEqual:@"align"]) {
    label.textAlignment = [UIUtil textAlignmentFromString:value];
  } else if ([name isEqual:@"maxNumberOfLines"]) {
    label.numberOfLines = [value intValue];
  } else {
    [super setProperty:name withValue:value forComponent:label];
  }
}

- (CGSize)getTextSize:(NSString*)text
                 font:(UIFont*)font
     maxNumberOfLines:(int)maxNumberOfLines
                width:(float)width
{
  CGSize size;
  if (maxNumberOfLines == 1) {
    size = [text sizeWithFont:font];
  } else {
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    if (maxNumberOfLines != 0) {
      // Get the size of one line.
      CGSize singleLineSize = [text sizeWithFont:font];
      maxSize.height = maxNumberOfLines*singleLineSize.height;
    }

    // Get the multiline size, but only adjust the height since we fit only
    // height for maxNumberOfLines != 1.
    size.width = width;
    size.height = [text sizeWithFont:font constrainedToSize:maxSize].height;
  }

  return size;
}
 
- (void)getTextSize:(NSMutableArray*)arguments
           withDict:(NSMutableDictionary*)options
{
  NSString* text = [options objectForKey:@"text"];
  UIFont* font = [UIUtil fontFromOptions:options]; 
  NSNumber* maxNumberOfLines = [options objectForKey:@"maxNumberOfLines"];
  NSNumber* width = [options objectForKey:@"width"];
  assert(text && font && maxNumberOfLines && width);

  CGSize size  = [self getTextSize:text 
                              font:font
                  maxNumberOfLines:[maxNumberOfLines intValue]
                             width:[width floatValue]];
  NSDictionary* sizeDict = 
      [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithFloat:size.width], @"width",
          [NSNumber numberWithFloat:size.height], @"height",
          nil];

  CDVPluginResult* result =
      [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                 messageAsDictionary:sizeDict];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}


- (void)sizeToFit:(NSMutableArray*)arguments
         withDict:(NSMutableDictionary*)options
{
  NSString* viewID = [options objectForKey:@"viewID"];
  TNUILabel* label = [[self class] lookupComponentWithID:viewID];
  assert(label && [label isKindOfClass:[TNUILabel class]]);

  CGRect newFrame = label.frame;
  newFrame.size = [self getTextSize:label.text
                               font:label.font
                   maxNumberOfLines:label.numberOfLines
                              width:label.bounds.size.width];
  label.frame = newFrame;

  CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  NSString* callbackID = [arguments objectAtIndex:0];
  [self writeJavascript:[result toSuccessCallbackString:callbackID]];
}

@end
