//
//  UISearchBar+RACAdditions.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/20/15.

#import <objc/runtime.h>
#import "UISearchBar+RACAdditions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

static void *UISearchBarRACCommandKey = &UISearchBarRACCommandKey;
static void *UISearchBarDisposableKey = &UISearchBarDisposableKey;

@implementation UISearchBar (RACAdditions)

- (RACSignal *)rac_textSignal {
    self.delegate = self;
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal != nil) return signal;
    
    /* Create signal from selector */
    signal = [[self rac_signalForSelector:@selector(searchBar:textDidChange:) fromProtocol:@protocol(UISearchBarDelegate)] map:^id(RACTuple *tuple) {
        return tuple.second;
    }];
    
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}

@end
