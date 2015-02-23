//
//  GLItemConfirmationView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/22/15.
//
//

#import "GLItemConfirmationView.h"

@implementation GLItemConfirmationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSLog(@"Init with frame");
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        NSLog(@"Init with coder");
    }
    
    return self;
}

- (void)awakeFromNib {
    NSLog(@"Awake from nib");
}

@end
