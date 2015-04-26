//
//  CAManualEntryView.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.

@import UIKit;

@class CAListObject;
@class RACSubject;
@class JVFloatLabeledTextField;

/**
 *  The view that appears when the user has scanned an item, allows editing of fields
 */
@interface CAManualEntryView : UIView <UITextFieldDelegate>

@property (weak, nonatomic) UITextField *activeField;

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *name;
@property (weak, nonatomic) IBOutlet UIButton *confirm;
@property (weak, nonatomic) IBOutlet UIButton *cancel;

@end
