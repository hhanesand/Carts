//
//  CAPullToCloseTransitionPresentationController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/6/15.

#import "CAPullToCloseTransitionPresentationController.h"

@implementation CAPullToCloseTransitionPresentationController

- (void)presentationTransitionWillBegin {
    //add the presented view to the heirarchy
    [[self containerView] addSubview:[self presentedView]];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    //nothing to do here
}

- (void)dismissalTransitionWillBegin {
    //again, nothing needs to be done here
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    //nothing here
}

- (CGRect)frameOfPresentedViewInContainerView {
    //return the full size of the screen (ie the entire container view)
    return [self containerView].bounds;
}

@end
