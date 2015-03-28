//
//  GLItemConfirmationView.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.
//
//

#import <UIKit/UIKit.h>
#import "GLReusableNibView.h"

@class GLListObject;

@interface GLItemConfirmationView : GLReusableNibView<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *brand;
@property (weak, nonatomic) IBOutlet UITextField *category;
@property (weak, nonatomic) IBOutlet UITextField *manufacturer;

@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *confirm;

- (void)bindWithListObject:(GLListObject *)listObject;

@property (weak, nonatomic) UITextField *activeField;

@end
