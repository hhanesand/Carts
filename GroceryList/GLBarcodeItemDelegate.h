//
//  GLBarcodeItemDelegate.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/2/15.
//
//

#import <Foundation/Foundation.h>

@class GLListItem;

@protocol GLBarcodeItemDelegate <NSObject>
- (void)didRecieveNewListItem:(GLListItem *)listItem;
@end
