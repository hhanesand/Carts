//
//  GLShareTableViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/20/15.

#import <UIKit/UIKit.h>
#import "GLUserTableViewCell.h"
#import "GLKeyboardResponderAnimator.h"

@interface GLShareCartViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, GLUserTableViewCellDelegate, GLKeyboardMovementResponderDelegate>

+ (instancetype)instance;

@end