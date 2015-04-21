//
//  GLManualEntryView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

#import "GLManualEntryView.h"
#import "GLBarcodeObject.h"
#import "GLListObject.h"


@implementation GLManualEntryView

- (void)initialize {
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Regular" size:12];
    self.name.floatingLabelFont = font;
    self.name.floatingLabelTextColor = [UIColor grayColor];
    self.name.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Regular" size:16.0]}];
}



@end
