//
//  CABingSessionManager.h
//  Carts
//
//  Created by Hakon Hanesand on 4/9/15.

@class CABarcodeObject;
@class RACSignal;

#import "CARACSessionManager.h"

@interface CABingSessionManager : CARACSessionManager

/**
 *  Searches bing for images of a particular barcode object
 *
 *  @param barcodeObject The bacode object to search for
 *
 *  @return A signal that will return the image url found on Bing and then complete and then return
 */
- (RACSignal *)bingImageRequestWithBarcodeObject:(CABarcodeObject *)barcodeObject;

@end
