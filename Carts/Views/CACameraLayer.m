//
//  CACameraLayer.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/26/15.

#import "CACameraLayer.h"

@import UIKit;

@interface CACameraLayer ()
@property (nonatomic) CGFloat lineLength;
@property (nonatomic) CGFloat reticuleCornerRadius;
@end

/**
 *  Draws a rounded "targeting" reticule on the screen for the user to position the barcode in
 */
@implementation CACameraLayer

+ (instancetype)layer {
    return [CACameraLayer init];
}

- (instancetype)initWithBounds:(CGRect)bounds cornerRadius:(CGFloat)radius lineLength:(CGFloat)length {
    if (self = [super init]) {
        self.lineLength = length;
        self.reticuleCornerRadius = radius;
        [self configureWithBounds:bounds];
    }
    
    return self;
}



- (void)configureWithBounds:(CGRect)bounds {
    self.lineWidth = 2;
    self.fillColor = [UIColor clearColor].CGColor;
    self.strokeColor = [UIColor whiteColor].CGColor;
    self.lineCap = kCALineJoinRound;
    self.opacity = 0.3;
    
    self.path = [self buildPathWithBounds:bounds].CGPath;
}

- (UIBezierPath *)buildPathWithBounds:(CGRect)bounds {
    return [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:self.reticuleCornerRadius];
}

@end
