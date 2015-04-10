//
//  GLBingSessionManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.

@class GLBarcodeObject;
@class RACSignal;

#import "GLRACSessionManager.h"

@interface GLBingSessionManager : GLRACSessionManager

/**
 *  Searches bing for images of a particular barcode object
 *
 *  @param barcodeObject The bacode object to search for
 *
 *  @return A signal that will return the image url found on Bing and then complete and then return
 */
- (RACSignal *)bingImageRequestWithBarcodeObject:(GLBarcodeObject *)barcodeObject;

@end
