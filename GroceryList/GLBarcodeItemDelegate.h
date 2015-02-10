//
//  GLBarcodeItemDelegate.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/10/15.
//
//

@class GLBarcodeItem;
#import <Foundation/Foundation.h>

@protocol GLBarcodeItemDelegate <NSObject>

- (void)didFinishLoadingImageForBarcodeItem:(GLBarcodeItem *)barcodeItem;

@end
