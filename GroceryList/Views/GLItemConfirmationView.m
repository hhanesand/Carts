//
//  GLItemConfirmationView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

#import "GLItemConfirmationView.h"
#import "GLBarcodeObject.h"
#import "GLListObject.h"

@interface GLItemConfirmationView ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *separators;
@end

@implementation GLItemConfirmationView

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
    self.brand.floatingLabelFont = font;
    self.category.floatingLabelFont = font;
    
    UIColor *gray = [UIColor grayColor];
    
    self.name.floatingLabelTextColor = gray;
    self.brand.floatingLabelTextColor = gray;
    self.category.floatingLabelTextColor = gray;
    
    UIColor *color = [UIColor whiteColor];
    
    self.name.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Regular" size:16.0]}];
    self.brand.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Brand" attributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Regular" size:16.0]}];
    self.category.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Category" attributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Regular" size:16.0]}];
}

- (void)bindWithListObject:(GLListObject *)listObject {
    [[self.name.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *value) {
        [listObject addUserModification:value forKey:@"name"];
    }];
    
    [[self.brand.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *value) {
        [listObject addUserModification:value forKey:@"brand"];
    }];
    
    [[self.category.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *value) {
        [listObject addUserModification:value forKey:@"category"];
    }];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self.separators enumerateObjectsUsingBlock:^(UIView *separator, NSUInteger idx, BOOL *stop) {
        separator.bounds = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(separator.bounds));
        
        [separator.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
            subview.bounds = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(separator.bounds));
        }];
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
