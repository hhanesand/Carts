//
//  GLBarcodeScannerDelegate.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/26/15.
//
//

#import <Foundation/Foundation.h>
@class GLScannerWrapperViewController;
@class GLBarcodeItem;

@protocol GLBarcodeScannerDelegate <NSObject>

- (void)scanner:(GLScannerWrapperViewController *)scannerContorller didRecieveBarcodeItems:(NSArray *)barcodeItems;

@end
