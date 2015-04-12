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
    }
    
    return self;
}

- (void)awakeFromNib {
    NSLog(@"the lord has awakened");
}

- (void)bindWithListObject:(GLListObject *)listObject {
    [[self.name.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *value) {
        [listObject addUserModification:value forKey:@"name"];
        NSLog(@"List item's modification dict %@", listObject.userModifications);
    }];
    
    [[self.brand.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *value) {
        [listObject addUserModification:value forKey:@"brand"];
        NSLog(@"List item's modification dict %@", listObject.userModifications);
    }];
    
    [[self.category.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *value) {
        [listObject addUserModification:value forKey:@"category"];
        NSLog(@"List item's modification dict %@", listObject.userModifications);
    }];
    
    [[self.manufacturer.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *value) {
        [listObject addUserModification:value forKey:@"manufacturer"];
        NSLog(@"List item's modification dict %@", listObject.userModifications);
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
