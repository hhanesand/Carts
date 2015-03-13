//
//  GLItemConfirmationView.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.
//
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField.h"

@class GLBarcodeObject;

@interface GLItemConfirmationView : UIVisualEffectView<UITextFieldDelegate>

- (instancetype)initWithBlurAndFrame:(CGRect)frame andBarcodeItem:(GLBarcodeObject *)barcodeItem;

@property (weak, nonatomic) UITextField *activeField;

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *brand;
@property (weak, nonatomic) IBOutlet UITextField *category;
@property (weak, nonatomic) IBOutlet UITextField *manufacturer;

@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *confirm;
@end
