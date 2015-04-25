//
//  GLUserTableViewCell.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/20/15.

#import <UIKit/UIKit.h>

@class PFUser;
@class GLUserTableViewCell;

@protocol GLUserTableViewCellDelegate <NSObject>
@optional
- (void)userDidTapAddFriendButtonInTableViewCell:(GLUserTableViewCell *)cell ;
@end

@interface GLUserTableViewCell : UITableViewCell

@property (nonatomic) id<GLUserTableViewCellDelegate> delegate;

- (void)bindWithUser:(PFUser *)user;

@end
