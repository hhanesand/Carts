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
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1];
}

@end
