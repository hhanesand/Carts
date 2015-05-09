//
//  UserTableViewCell.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/9/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

@objc protocol UserTableViewCellDelegate {
    optional func userDidTapAddFriendButtonInTableViewCell(tableViewCell: UserTableViewCell)
}

class UserTableViewCell: UITableViewCell {
    
    func bindWithUser(user: PFUser) {
        username.text = user["name"]
        
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:user[@"picture"]]];
        //    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        //
        //    [self.image setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        //    self.image.image = image;
        //    [self.image setNeedsDisplay];
        //    } failure:nil];
        //    }
        
    }

    //    - (IBAction)userDidTapFollowButton:(id)sender {
    //    if ([self.delegate respondsToSelector:@selector(userDidTapAddFriendButtonInTableViewCell:)]) {
    //    [self.delegate userDidTapAddFriendButtonInTableViewCell:self];
    //    }
    
}
