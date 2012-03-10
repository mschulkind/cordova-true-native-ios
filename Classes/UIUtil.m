#import "UIUtil.h"

@implementation UIUtil

+ (UIColor*)colorFromString:(NSString*)colorString
{
  UIColor* color;

  if ([colorString characterAtIndex:0] == '#') {
    unsigned int hexValue;
    [[NSScanner scannerWithString:[colorString substringFromIndex:1]]
                       scanHexInt:&hexValue];
    NSInteger red, green, blue;
    switch([colorString length]) {
      case 4:
        red = ((hexValue & 0xF00) >> 4) + ((hexValue & 0xF00) >> 8);
        green = (hexValue & 0xF0) + ((hexValue & 0xF0) >> 4);
        blue = ((hexValue & 0xF) << 4) + (hexValue & 0xF);
        break;

      case 7:
        red = (hexValue & 0xFF0000) >> 16;
        green = (hexValue & 0xFF00) >> 8;
        blue = hexValue & 0xFF;
        break;

      default:
        NSLog(@"Invalid hex color code '%@'.", colorString);
        assert(false);
    }

    color = [UIColor colorWithRed:red/255.0 
                            green:green/255.0 
                             blue:blue/255.0 
                            alpha:1.0];
  } else {
    NSString* methodName = [NSString stringWithFormat:@"%@Color", colorString];
    SEL selector = NSSelectorFromString(methodName);

    if (![UIColor respondsToSelector:selector]) {
      NSLog(@"Color '%@' not found.", colorString);
      assert(false);
    } 

    color = [UIColor performSelector:selector];
  }
  
  return color;
}

+ (UIFont*)fontFromOptions:(NSDictionary*)options
{
  NSString* fontFamily = [options objectForKey:@"fontFamily"];
  assert(fontFamily);
  // Remove any spaces.
  fontFamily = [fontFamily stringByReplacingOccurrencesOfString:@" " 
                                                     withString:@""];

  NSString* fontSizeString = [options objectForKey:@"fontSize"];
  CGFloat fontSizeFloat;
  if (fontSizeString) {
    fontSizeFloat = [fontSizeString floatValue];
  } else {
    fontSizeFloat = 17;
  }

  UIFont* font;
  NSString* fontWeight = [options objectForKey:@"fontWeight"];
  if (fontWeight) {
    if (![fontWeight isEqual:@"bold"]) {
      NSLog(@"Invalid fontWeight '%@'", fontWeight);
      assert(false);
    }

    // For some crazy reason, iPhone fonts are named inconsistently, so we have
    // to try both -Bold and -BoldMT.
    font = 
        [UIFont 
            fontWithName:[NSString stringWithFormat:@"%@-Bold", fontFamily]
                    size:fontSizeFloat];
    if (!font) {
      font = 
          [UIFont fontWithName:
              [NSString stringWithFormat:@"%@-BoldMT", fontFamily]
              size:fontSizeFloat];
    }
  } else {
    font = [UIFont fontWithName:fontFamily size:fontSizeFloat];
  }
  assert(font);
  return font;
}

// Borrowed from here:
// http://stackoverflow.com/questions/990976/how-to-create-a-colored-1x1-uiimage-on-the-iphone-dynamically
+ (UIImage*)imageWithColor:(UIColor*)color
{
  CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSetFillColorWithColor(context, [color CGColor]);
  CGContextFillRect(context, rect);

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}

+ (UITextAlignment)textAlignmentFromString:(NSString*)string
{
  if ([string isEqual:@"left"]) {
    return UITextAlignmentLeft;
  } else if ([string isEqual:@"center"]) {
    return UITextAlignmentCenter;
  } else if ([string isEqual:@"right"]) {
    return UITextAlignmentRight;
  } else {
    assert(false);
  }
}

@end
