//
//  GLListOverviewTableViewCell.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/19/15.

#import "GLListOverviewTableViewCell.h"

@implementation GLListOverviewTableViewCell

- (void)setCartText:(NSString *)text {
    self.cart.text = [text stringByAppendingString:@"'s Cart"];
}

@end
