//
//  CAUserTableViewCell.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/20/15.

#import "CAUserTableViewCell.h"
#import <Parse/Parse.h>

@interface CAUserTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *username;
@end

@implementation CAUserTableViewCell

- (void)bindWithUser:(PFUser *)user {
    self.username.text = user.username;
}

- (IBAction)userDidTapFollowButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(userDidTapAddFriendButtonInTableViewCell:)]) {
        [self.delegate userDidTapAddFriendButtonInTableViewCell:self];
    }
}

@end
