//
//  GLBarcodeItemDelegate.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/10/15.
//
//

#import <Foundation/Foundation.h>

@class GLBarcodeItem;

@protocol GLBarcodeItemDelegate <NSObject>

- (void)didReceiveNewBarcodeItem;
- (void)didReceiveUpdateForBarcodeItem;

@end
