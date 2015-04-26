//
//  CATableViewCell.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.

@import UIKit;

/**
 *  The cell used in th CATableViewController
 */
@interface CATableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *brand;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@end
