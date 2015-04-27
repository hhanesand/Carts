//
//  UIColor+CAColor.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.

@import UIKit;

@interface UIColor (CAColor)

/**
 *  Creates a color with the given components, specified from 0..255
 *
 *  @param red   The amount of red
 *  @param green The amount of green
 *  @param blue  The amount of blue
 *
 *  @return The color as a result of dividing each component by 255.0f and then passing it to a UIColor method
 */
+ (UIColor *)colorWithRed:(float)red green:(float)green blue:(float)blue;

/**
 *  Creates an image with the background color
 *
 *  @param color The color for the image
 *
 *  @return A 1x1 UIImage with the given background color
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIColor *)facebookButtonBackgroundColor;
+ (UIColor *)twitterButtonBackgroundColor;
+ (UIColor *)blueBlackgroundColor;

@end
