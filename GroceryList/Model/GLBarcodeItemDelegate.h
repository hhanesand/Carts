//
//  GLBarcodeItemDelegate.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/2/15.

@import Foundation;

@class GLListObject;

@protocol GLBarcodeItemDelegate <NSObject>

/**
 *  Called when the delegate needs to handle a new barcode that has been scanned
 *
 *  @param listItem The new item the user wants to add to his list
 */
- (void)didRecieveNewListItem:(GLListObject *)listItem;

@end
