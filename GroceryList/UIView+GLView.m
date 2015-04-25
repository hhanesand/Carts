//
//  UIView+GLView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/23/15.

#import "UIView+GLView.h"

@implementation UIView (GLView)

- (void)setMaskToRoundedCorners:(UIRectCorner)corners withRadii:(CGFloat)radius {
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = self.bounds;
    shape.path = rounded.CGPath;
    
    self.layer.mask = shape;
}

@end
