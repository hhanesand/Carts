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
@class GLScanningSession;

@protocol GLBarcodeScannerDelegate <NSObject>

@required
- (void)scanner:(GLScanningSession *)scanner didRecieveBarcodeItem:(GLBarcodeItem *)item;

@end
