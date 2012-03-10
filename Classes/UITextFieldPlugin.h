#import "UIViewPlugin.h"

@class TNUITextField;

@interface UITextFieldPlugin : UIViewPlugin <UITextFieldDelegate> {
 @private
  TNUITextField* textFieldBeingEdited_;
}

@property (nonatomic, retain) TNUITextField* textFieldBeingEdited;

@end
