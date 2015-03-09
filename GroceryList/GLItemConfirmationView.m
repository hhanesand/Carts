//
//  GLItemConfirmationView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.
//
//

#import "GLItemConfirmationView.h"
#import "GLBarcodeItem.h"

@implementation GLItemConfirmationView

- (instancetype)initWithBlurAndFrame:(CGRect)frame andBarcodeItem:(GLBarcodeItem *)barcodeItem {
    if (self = [super initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]]) {
        self.frame = frame;
        [self loadNib];
        [self setupViewsWithBarcodeItem:barcodeItem];
    }
    
    return self;
}

- (void)loadNib {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GLItemConfirmationView" owner:self options:nil];
    NSLog(@"Number of views %@", @([nib count]));

    UIView *view = [nib objectAtIndex:0];
    
    view.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    #warning think about removing the extra view added by nib loading?
    [[self contentView] addSubview:view];
}

- (void)setupViewsWithBarcodeItem:(GLBarcodeItem *)barcodeItem {
    self.name.text = barcodeItem.name;
    self.brand.text = barcodeItem.brand;
    self.category.text = barcodeItem.category;
    self.manufacturer.text = barcodeItem.manufacturer;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

@end
