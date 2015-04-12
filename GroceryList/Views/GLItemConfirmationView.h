//
//  GLItemConfirmationView.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.

@import UIKit;

@class GLListObject;
@class RACSubject;
@class JVFloatLabeledTextField;

/**
 *  The view that appears when the user has scanned an item, allows editing of fields
 */
@interface GLItemConfirmationView : UIView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *name;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *brand;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *category;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *manufacturer;

@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *confirm;

- (void)bindWithListObject:(GLListObject *)listObject;

@property (weak, nonatomic) UITextField *activeField;

@end
