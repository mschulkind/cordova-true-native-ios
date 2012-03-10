#import "UIDatePickerViewPlugin.h"

@interface TNUIDatePickerView : UIDatePicker {
 @private
}
@end

@implementation TNUIDatePickerView

@end

@implementation UIDatePickerViewPlugin

+ (Class)uiKitSubclass
{
  return [TNUIDatePickerView class];
}

- (void)setupComponent:(TNUIDatePickerView*)datePickerView
           withOptions:(NSDictionary*)options
{
  [super setupComponent:datePickerView withOptions:options];

  datePickerView.datePickerMode = UIDatePickerModeDate;

  [self setProperties:
    [NSArray arrayWithObjects:@"minimumDate", @"maximumDate", @"date", nil]
    forComponent:datePickerView
    fromOptions:options];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUIDatePickerView*)datePickerView
{
  if ([name isEqual:@"date"]) {
    return 
        [NSNumber numberWithLongLong:
            [datePickerView.date timeIntervalSince1970] * 1000];
  } else {
    return [super getProperty:name forComponent:datePickerView];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUIDatePickerView*)datePickerView
{
  if ([name isEqual:@"minimumDate"]) {
    datePickerView.minimumDate = 
        [NSDate dateWithTimeIntervalSince1970:[value doubleValue] / 1000];
  } else if ([name isEqual:@"maximumDate"]) {
    datePickerView.maximumDate = 
        [NSDate dateWithTimeIntervalSince1970:[value doubleValue] / 1000];
  } else if ([name isEqual:@"date"]) {
    datePickerView.date = 
        [NSDate dateWithTimeIntervalSince1970:[value doubleValue] / 1000];
  } else {
    [super setProperty:name 
             withValue:value 
          forComponent:datePickerView];
  }
}

@end
