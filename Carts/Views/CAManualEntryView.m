//
//  CAManualEntryView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

#import "CAManualEntryView.h"
#import "CABarcodeObject.h"
#import "CAListObject.h"

@implementation CAManualEntryView

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Regular" size:12];
    self.name.floatinCAabelFont = font;
    self.name.floatinCAabelTextColor = [UIColor grayColor];
    self.name.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Regular" size:16.0]}];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
