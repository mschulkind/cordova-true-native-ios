@interface UIUtil : NSObject {
}

+ (UIColor*)colorFromString:(NSString*)colorString;
+ (UIFont*)fontFromOptions:(NSDictionary*)options;
+ (UIImage*)imageWithColor:(UIColor*)color;
+ (UITextAlignment)textAlignmentFromString:(NSString*)string;

@end
