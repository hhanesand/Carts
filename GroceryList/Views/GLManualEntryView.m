//
//  GLItemConfirmationView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

#import "GLManualEntryView.h"
#import "GLBarcodeObject.h"
#import "GLListObject.h"

@interface GLManualEntryView ()
@property (weak, nonatomic) IBOutlet UIView *separator;
@end

@implementation GLManualEntryView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *nibView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
        nibView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        self.backgroundColor = [UIColor clearColor];
        
        if (CGRectIsEmpty(frame)) {
            self.bounds = nibView.bounds;
        }
        
        [self addSubview:nibView];
        
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Regular" size:12];
    self.name.floatingLabelFont = font;
    
    UIColor *gray = [UIColor grayColor];
    
    self.name.floatingLabelTextColor = gray;
    
    UIColor *color = [UIColor whiteColor];
    
    self.name.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Regular" size:16.0]}];
}

- (void)bindWithListObject:(GLListObject *)listObject {
    [[self.name.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *value) {
        [listObject addUserModification:value forKey:@"name"];
    }];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.separator.bounds = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(self.separator.bounds));
        
    [self.separator.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        subview.bounds = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(self.separator.bounds));
    }];
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
