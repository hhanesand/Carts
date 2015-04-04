//
//  GLItemConfirmationView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.
//
//

#import "GLItemConfirmationView.h"
#import "GLBarcodeObject.h"
#import "GLListObject.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

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

- (void)bindWithListObject:(GLListObject *)listObject {
    self.name.text = [listObject getName];
    self.brand.text = [listObject getBrand];
    self.category.text = [listObject getCategory];
    self.manufacturer.text = [listObject getManufacturer];
    
    [[[self.name.rac_textSignal distinctUntilChanged] skip:1] subscribeNext:^(NSString *value) {
        [listObject addUserModification:value forKey:@"name"];
        NSLog(@"List item's modification dict %@", listObject.userModifications);
    }];
    
    [[[self.brand.rac_textSignal distinctUntilChanged] skip:1] subscribeNext:^(NSString *value) {
        [listObject addUserModification:value forKey:@"brand"];
        NSLog(@"List item's modification dict %@", listObject.userModifications);
    }];
    
    [[[self.category.rac_textSignal distinctUntilChanged] skip:1] subscribeNext:^(NSString *value) {
        [listObject addUserModification:value forKey:@"category"];
        NSLog(@"List item's modification dict %@", listObject.userModifications);
    }];
    
    [[[self.manufacturer.rac_textSignal distinctUntilChanged] skip:1] subscribeNext:^(NSString *value) {
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
