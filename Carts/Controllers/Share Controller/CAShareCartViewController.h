//
//  CAShareTableViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/20/15.

#import <UIKit/UIKit.h>
#import "CAUserTableViewCell.h"
#import "CAKeyboardResponderAnimator.h"

@interface CAShareCartViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CAUserTableViewCellDelegate, CAKeyboardMovementResponderDelegate>

+ (instancetype)instance;

@end