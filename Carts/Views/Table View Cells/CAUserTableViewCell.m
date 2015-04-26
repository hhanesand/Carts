//
//  CAUserTableViewCell.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/20/15.

#import "CAUserTableViewCell.h"
#import <Parse/Parse.h>
#import "UIImageView+AFNetworking.h"

@interface CAUserTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@end

@implementation CAUserTableViewCell

- (void)bindWithUser:(PFUser *)user {
    self.username.text = user[@"name"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:user[@"picture"]]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self.image setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.image.image = image;
        [self.image setNeedsDisplay];
    } failure:nil];
}

- (IBAction)userDidTapFollowButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(userDidTapAddFriendButtonInTableViewCell:)]) {
        [self.delegate userDidTapAddFriendButtonInTableViewCell:self];
    }
}

@end
