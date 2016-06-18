//
//  CABarcodeScannerDelegate.h
//  Carts
//
//  Created by Hakon Hanesand on 2/26/15.

@import Foundation;

@class CAScanningSession;
@class CABarcode;

/**
 *  Delegate for the barcode scanner
 */
@protocol CABarcodeScannerDelegate <NSObject>

@required
- (void)scanner:(CAScanningSession *)scanner didRecieveBarcode:(CABarcode *)barcode;

@end
