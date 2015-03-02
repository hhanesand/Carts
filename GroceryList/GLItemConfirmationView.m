//
//  GLItemConfirmationView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.
//
//

#import "GLItemConfirmationView.h"

@implementation GLItemConfirmationView

- (instancetype)initWithBlurAndFrame:(CGRect)frame {
    if (self = [super initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]]) {
        self.frame = frame;
        NSLog(@"Bounds after setting frame %@", NSStringFromCGRect(self.bounds));
        [self loadNib];
        [self setupViews];
        
        self.textFields = @[self.name, self.brand, self.manufacturer, self.category];
    }
    
    return self;
}

- (void)loadNib {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"GLItemConfirmationView" owner:self options:nil] objectAtIndex:0];
    view.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    NSLog(@"Number of subviews for nib file %lu", (unsigned long)[[view subviews] count]);
    
    #warning think about removing the extra view added by nib loading?
    [[self contentView] addSubview:view];
}

- (void)setupViews {
    [self.name setReturnKeyType:UIReturnKeyDone];
    [self.brand setReturnKeyType:UIReturnKeyDone];
    [self.manufacturer setReturnKeyType:UIReturnKeyDone];
    [self.category setReturnKeyType:UIReturnKeyDone];
    
    [self.name setKeyboardAppearance:UIKeyboardAppearanceDark];
    [self.brand setKeyboardAppearance:UIKeyboardAppearanceDark];
    [self.manufacturer setKeyboardAppearance:UIKeyboardAppearanceDark];
    [self.category setKeyboardAppearance:UIKeyboardAppearanceDark];
    
    self.name.delegate = self;
    self.brand.delegate = self;
    self.manufacturer.delegate = self;
    self.category.delegate = self;
    
    [self.name setPlaceholder:@"Product Name" floatingTitle:@"Product Name"];
    [self.brand setPlaceholder:@"Brand" floatingTitle:@"Brand"];
    [self.manufacturer setPlaceholder:@"Manufacturer" floatingTitle:@"Manufacturer"];
    [self.category setPlaceholder:@"Category" floatingTitle:@"Category"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
