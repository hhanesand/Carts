//
//  CAUserTableViewCell.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/20/15.

#import <UIKit/UIKit.h>

@class PFUser;
@class CAUserTableViewCell;

@protocol CAUserTableViewCellDelegate <NSObject>
@optional
- (void)userDidTapAddFriendButtonInTableViewCell:(CAUserTableViewCell *)cell ;
@end

@interface CAUserTableViewCell : UITableViewCell

@property (nonatomic) id<CAUserTableViewCellDelegate> delegate;

- (void)bindWithUser:(PFUser *)user;

@end
