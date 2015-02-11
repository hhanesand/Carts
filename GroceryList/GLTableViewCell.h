//
//  GLTableViewCell.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface GLTableViewCell : UITableViewCell

- (void)setNameOfProduct:(NSString *)name;
- (void)setImageOfProduct:(UIImage *)image;

@end
