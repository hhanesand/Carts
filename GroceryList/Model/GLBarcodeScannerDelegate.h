//
//  GLBarcodeScannerDelegate.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/26/15.
//
//

@import Foundation;

@class GLScanningSession;
@class GLBarcode;

@protocol GLBarcodeScannerDelegate <NSObject>

@required
- (void)scanner:(GLScanningSession *)scanner didRecieveBarcode:(GLBarcode *)barcode;

@end
