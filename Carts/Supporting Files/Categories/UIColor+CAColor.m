//
//  UIColor+CAColor.m
//  Carts
//
//  Created by Hakon Hanesand on 3/4/15.

#import "UIColor+CAColor.h"

@import QuartzCore;

@implementation UIColor (CAColor)

+ (UIColor *)colorWithRed:(float)red green:(float)green blue:(float)blue {
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1];
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIColor *)facebookButtonBackgroundColor {
    return [UIColor colorWithRed:58.0f/255.0f green:89.0f/255.0f blue:152.0f/255.0f alpha:1.0f];
}

+ (UIColor *)twitterButtonBackgroundColor {
    return [UIColor colorWithRed:45.0f/255.0f green:170.0f/255.0f blue:1.0f alpha:1.0f];
}

+ (UIColor *)blueBlackgroundColor {
    return [UIColor colorWithRed:0.14 green:0.87 blue:0.75 alpha:1];
}

@end
