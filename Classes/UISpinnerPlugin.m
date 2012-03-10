#import "UISpinnerPlugin.h"

@interface TNUISpinner : UIActivityIndicatorView {
 @private
}
@end

@implementation TNUISpinner

@end

@implementation UISpinnerPlugin

+ (Class)uiKitSubclass
{
  return [TNUISpinner class];
}

- (void)setupComponent:(TNUISpinner*)spinner withOptions:(NSDictionary*)options
{
  [super setupComponent:spinner withOptions:options];

  spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

  [self setProperties:
    [NSArray arrayWithObjects:nil]
    forComponent:spinner
    fromOptions:options];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUISpinner*)spinner
{
  if ([name isEqual:@"hidden"]) {
    return [NSNumber numberWithBool:spinner.isAnimating];
  } else {
    return [super getProperty:name forComponent:spinner];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUISpinner*)spinner
{
  if ([name isEqual:@"hidden"]) {
    if([value boolValue]) {
      [spinner stopAnimating];
    } else {
      [spinner startAnimating];
    }
  } else {
    [super setProperty:name 
             withValue:value 
          forComponent:spinner];
  }
}

@end
