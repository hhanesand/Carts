//
//  GLTweakWindow.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/7/15.
//
//

#import "GLTweakWindow.h"
#import <Tweaks/FBTweakViewController.h>
#import <Tweaks/FBTweakStore.h>

@implementation GLTweakWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *threeFinger = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapWithThreeFingers)];
        threeFinger.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:threeFinger];
    }
    
    return self;
}

- (void)didTapWithThreeFingers {
    UIViewController *visibleViewController = self.rootViewController;
    while (visibleViewController.presentedViewController != nil) {
        visibleViewController = visibleViewController.presentedViewController;
    }
    
    // Prevent double-presenting the tweaks view controller.
    if (![visibleViewController isKindOfClass:[FBTweakViewController class]]) {
        FBTweakStore *store = [FBTweakStore sharedInstance];
        FBTweakViewController *viewController = [[FBTweakViewController alloc] initWithStore:store];
        viewController.tweaksDelegate = self;
        [visibleViewController presentViewController:viewController animated:YES completion:NULL];
    }
}

- (void)tweakViewControllerPressedDone:(FBTweakViewController *)tweakViewController
{
    [tweakViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
