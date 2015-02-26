//
//  GLTableViewCell.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import <UIKit/UIKit.h>

@interface GLTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *details;

@end
