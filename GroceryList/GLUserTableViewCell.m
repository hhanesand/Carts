//
//  GLUserTableViewCell.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/20/15.

#import "GLUserTableViewCell.h"

@interface GLUserTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *username;
@end

@implementation GLUserTableViewCell

- (void)bindWithUser:(GLUser *)user {
    self.username.text = user.username;
}

- (IBAction)userDidTapFollowButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(userDidTapAddFriendButtonInTableViewCell:)]) {
        [self.delegate userDidTapAddFriendButtonInTableViewCell:self];
    }
}

@end
