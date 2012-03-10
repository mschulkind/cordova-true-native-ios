#import "UIPickerViewPlugin.h"

@interface TNUIPickerView : UIPickerView 
    <UIPickerViewDelegate, UIPickerViewDataSource> {
 @private
  NSArray* entries_;
}

@property (nonatomic, retain) NSArray* entries;

@end

@implementation TNUIPickerView

@synthesize entries = entries_;

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
  return 1;
}

- (NSInteger)pickerView:(UIPickerView*)pickerView 
    numberOfRowsInComponent:(NSInteger)component
{
  return [entries_ count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView 
            titleForRow:(NSInteger)row 
           forComponent:(NSInteger)component
{
  assert(component == 0);
  assert(row < [entries_ count]);
  return [entries_ objectAtIndex:row];
}

@end

@implementation UIPickerViewPlugin

+ (Class)uiKitSubclass
{
  return [TNUIPickerView class];
}

- (void)setupComponent:(TNUIPickerView*)pickerView
           withOptions:(NSDictionary*)options
{
  [super setupComponent:pickerView withOptions:options];

  pickerView.delegate = pickerView;
  pickerView.dataSource = pickerView;
  pickerView.showsSelectionIndicator = YES;

  [self setProperties:
    [NSArray arrayWithObjects:@"entries", @"selectedRow", nil]
    forComponent:pickerView
    fromOptions:options];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUIPickerView*)pickerView
{
  if ([name isEqual:@"selectedRow"]) {
    return [NSNumber numberWithInt:[pickerView selectedRowInComponent:0]];
  } else {
    return [super getProperty:name forComponent:pickerView];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUIPickerView*)pickerView
{
  if ([name isEqual:@"entries"]) {
    assert([value isKindOfClass:[NSArray class]]);
    pickerView.entries = value;
    [pickerView reloadAllComponents];
  } else if ([name isEqual:@"selectedRow"]) {
    [pickerView selectRow:[value intValue] inComponent:0 animated:NO];
  } else {
    [super setProperty:name 
             withValue:value 
          forComponent:pickerView];
  }
}

@end
