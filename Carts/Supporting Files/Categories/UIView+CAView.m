//
//  UIView+CAView.m
//  Carts
//
//  Created by Hakon Hanesand on 4/23/15.

#import "UIView+CAView.h"

@implementation UIView (CAView)

- (void)setMaskToRoundedCorners:(UIRectCorner)corners withRadii:(CGFloat)radius {
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = self.bounds;
    shape.path = rounded.CGPath;
    
    self.layer.mask = shape;
}

@end
