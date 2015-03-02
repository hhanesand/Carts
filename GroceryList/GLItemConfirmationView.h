//
//  GLItemConfirmationView.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.
//
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField.h"

@interface GLItemConfirmationView : UIVisualEffectView<UITextFieldDelegate>

- (instancetype)initWithBlurAndFrame:(CGRect)frame;

@property (nonatomic) NSArray *textFields;

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *manufacturer;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *category;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *name;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *brand;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *confirm;
@end
