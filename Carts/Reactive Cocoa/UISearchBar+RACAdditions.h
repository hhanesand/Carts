//
//  UISearchBar+RACAdditions.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/20/15.

#import <UIKit/UIKit.h>

@class RACSignal;

@interface UISearchBar (RACAdditions)

- (RACSignal *)rac_textSignal;

@end
