//
//  GLCameraLayer.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/26/15.
//
//

@import UIKit;

#import "GLCameraLayer.h"

@interface GLCameraLayer ()
@property (nonatomic) CGFloat lineLength;
@property (nonatomic) CGFloat cornerRadius;
@end

/**
 *  Draws a rounded "targeting" reticule on the screen for the user to position the barcode in
 */
@implementation GLCameraLayer

+ (instancetype)layer {
    return [GLCameraLayer init];
}

- (instancetype)initWithBounds:(CGRect)bounds cornerRadius:(CGFloat)radius lineLength:(CGFloat)length {
    if (self = [super init]) {
        self.lineLength = length;
        self.cornerRadius = radius;
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

    NSLog(@"Shape bounds %@", NSStringFromCGRect(bounds));
    CGFloat skipLength = CGRectGetHeight(bounds) - self.cornerRadius - self.lineLength;
    CGFloat combinedLength = self.cornerRadius + self.lineLength;
//    
//    self.lineDashPattern = @[@(combinedLength), @(skipLength), @(combinedLength * 2), @(skipLength), @(combinedLength * 2), @(skipLength), @(combinedLength * 2), @(skipLength), @(combinedLength)];
    
    self.path = [self buildPathWithBounds:bounds].CGPath;
}

- (UIBezierPath *)buildPathWithBounds:(CGRect)bounds {
    return [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:self.cornerRadius];
}

@end