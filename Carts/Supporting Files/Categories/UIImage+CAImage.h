//
//  UIImage+GLImage.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.
//
//

@import CoreMedia;
@import UIKit;

@interface UIImage (GLImage)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

+ (UIImage *)imageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;

@end
