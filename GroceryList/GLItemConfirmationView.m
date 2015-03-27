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

@interface GLItemConfirmationView ()
@property (nonatomic, weak) GLListObject *listObject;
@end

@implementation GLItemConfirmationView

- (instancetype)initWithBlurAndFrame:(CGRect)frame listObject:(GLListObject *)listObject {
    if (self = [super initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]) {
        self.frame = frame;
        [self loadNib];
        [self setupViewWithListObject:listObject];
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

- (void)setupViewWithListObject:(GLListObject *)listObject {
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
