//
//  GLTableViewCell.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import "GLTableViewCell.h"

@implementation GLTableViewCell

- (void)awakeFromNib {
}

- (void)layoutSubviews {
    //self.label.text = @"SALAD";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.label.text = @"POO";
    } else {
        self.label.text = @"PHONE";
    }
}

@end
