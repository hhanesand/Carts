//
//  UIView+GLView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.
//
//

#import "UIView+GLView.h"

@implementation UIView (GLView)

- (UIImage *)screenshotInGraphicsContext {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
