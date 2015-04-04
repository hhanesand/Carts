//
//  GLTableViewCell.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import <UIKit/UIKit.h>

@interface GLTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *brand;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@end
