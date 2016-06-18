//
//  UIImage+CAImage.h
//  Carts
//
//  Created by Hakon Hanesand on 4/9/15.
//
//

@import CoreMedia;
@import UIKit;

@interface UIImage (CAImage)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

+ (UIImage *)imageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;

@end
