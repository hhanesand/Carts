//
//  GLProgressHUD.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/13/15.

#import "GLProgressHUD.h"

@implementation GLProgressHUD

+ (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        [super show];
    });
}

+ (void)showSuccessWithStatus:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
        [super showSuccessWithStatus:string];
    });
}

+ (void)showErrorWithStatus:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
        [super showErrorWithStatus:string];
    });
}

@end
