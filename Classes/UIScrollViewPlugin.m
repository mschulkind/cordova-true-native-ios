#import "UIScrollViewPlugin.h"

@interface TNUIScrollView : UIScrollView {
 @private
}
@end

@implementation TNUIScrollView

@end

@implementation UIScrollViewPlugin

+ (Class)uiKitSubclass
{
  return [TNUIScrollView class];
}

- (void)setupComponent:(TNUIScrollView*)scrollView withOptions:(NSDictionary*)options
{
  [super setupComponent:scrollView withOptions:options];

  [self setProperties:
    [NSArray arrayWithObjects:@"contentHeight", @"contentWidth", nil]
    forComponent:scrollView
    fromOptions:options];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUIScrollView*)scrollView
{
  if (false) {
  } else {
    return [super getProperty:name forComponent:scrollView];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUIScrollView*)scrollView
{
  if ([name isEqual:@"contentHeight"]) {
    CGSize newSize = scrollView.contentSize;
    newSize.height = [value floatValue];
    scrollView.contentSize = newSize;
  } else if ([name isEqual:@"contentWidth"]) {
    CGSize newSize = scrollView.contentSize;
    newSize.width = [value floatValue];
    scrollView.contentSize = newSize;
  } else {
    [super setProperty:name 
             withValue:value 
          forComponent:scrollView];
  }
}

@end
