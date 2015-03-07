//
//  UIColor+GLColor.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.
//
//

#import "UIColor+GLColor.h"

@implementation UIColor (GLColor)

+ (UIColor *)colorWithRed:(float)red green:(float)green blue:(float)blue {
    return [UIColor colorWithRed:red/255.0 green:green/255 blue:blue/255 alpha:1];
}

@end
