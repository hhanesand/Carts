//
//  GLBarcodeItemDelegate.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/2/15.

@import Foundation;

@class GLListObject;

@protocol GLBarcodeItemDelegate <NSObject>
- (void)didRecieveNewListItem:(GLListObject *)listItem;
@end
