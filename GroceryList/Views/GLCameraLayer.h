//
//  GLCameraLayer.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/26/15.

@import QuartzCore;

@interface GLCameraLayer : CAShapeLayer

- (instancetype)initWithBounds:(CGRect)bounds cornerRadius:(CGFloat)radius lineLength:(CGFloat)lineLength;

@end
