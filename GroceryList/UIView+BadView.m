//
//  UIView+BadView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/25/15.
//
//

#import <UIKit/UIKit.h>
#import "UIView+BadView.h"
#import <objc/runtime.h>

void SEViewAlertForUnsafeBackgroundCalls() {
    NSLog(@"----------------------------------------------------------------------------------");
    NSLog(@"Background call to setAnimationsEnabled: detected. This method is not thread safe.");
    NSLog(@"Set a breakpoint at SEUIViewDidSetAnimationsOffMainThread to inspect this call.");
    NSLog(@"----------------------------------------------------------------------------------");
}

@implementation UIView (BadView)


+ (void)load
{
    method_exchangeImplementations(class_getInstanceMethod(object_getClass(self), @selector(setAnimationsEnabled:)),
                                   class_getInstanceMethod(object_getClass(self), @selector(SE_setAnimationsEnabled:)));
}

+ (void)SE_setAnimationsEnabled:(BOOL)enabled
{
    if (![NSThread isMainThread]) {
        SEViewAlertForUnsafeBackgroundCalls();
    }
    [self SE_setAnimationsEnabled:enabled];
}

@end
