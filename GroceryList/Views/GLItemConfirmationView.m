//
//  GLItemConfirmationView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLItemConfirmationView.h"
#import "GLBarcodeObject.h"
#import "GLListObject.h"

@implementation GLItemConfirmationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSArray *nibFile = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        NSAssert([nibFile count] == 1 && [[nibFile firstObject] isMemberOfClass:[self class]], @"Error in nib loading, must be one top level object with class of %@", NSStringFromClass([self class]));
        UIView *topLevelView = [nibFile firstObject];
        topLevelView.frame = frame;
        
        if (CGRectIsEmpty(frame)) {
            self.bounds = topLevelView.bounds;
        }
        
        [self addSubview:topLevelView];
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
