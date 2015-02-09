//
//  GLTableViewCell.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import "GLTableViewCell.h"

@interface GLTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@end

@implementation GLTableViewCell

- (void)awakeFromNib {
}

- (void)layoutSubviews {
    for (UIView *subview in self.contentView.superview.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"SeparatorView"]) {
            subview.hidden = NO;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setNameOfProduct:(NSString *)name {
    self.productName.text = name;
    [self.productName sizeToFit];
}

- (void)setImageOfProduct:(UIImage *)image {
    self.productImage.image = image;
}

@end
