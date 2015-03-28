//
//  GLReusableNibView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/28/15.
//
//

#import "GLReusableNibView.h"

@implementation GLReusableNibView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.nibView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
        self.nibView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        self.backgroundColor = [UIColor clearColor];
        
        if (CGRectIsEmpty(frame)) {
            self.bounds = self.nibView.bounds;
        }
        
        [self addSubview:self.nibView];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self addSubview:self.nibView];
    }
    
    return self;
}

@end
