//
//  UIView+RecursiveInteraction.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/24/15.
//
//

#import "UIView+RecursiveInteraction.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation UIView (RecursiveInteraction)

- (void)setRecursiveInteraction:(BOOL)isInteractive {
    self.userInteractionEnabled = isInteractive;
    
    [self.subviews.rac_sequence.signal doNext:^(UIView *subview) {
        [subview setRecursiveInteraction:isInteractive];
    }];
}

@end
