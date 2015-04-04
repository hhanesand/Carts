//
//  GLBarcodeFetchManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/2/15.
//
//

#import <Foundation/Foundation.h>

#import "GLFactualManager.h"

@class GLBarcode;
@class RACSignal;

@interface GLBarcodeFetchManager : NSObject

/**
 *  Fetches information about a barcode by :
 *  1 : Check parse if the barcode is there, if it is return the GLListObject on the RACSignal
 *  2 : If parse does not have it, check with Factual and Bing for information and image, respectively and return a new GLListObject on the signal containing the information
 *  3 : If neither parse nor factual have the barcode, return a empty GLListObject for the user to fill out on the signal
 *
 *  @param barcode The scanned barcode to search for
 *
 *  @return The signal that returns one GLListObject and then completes
 */
- (RACSignal *)fetchProductInformationForBarcode:(GLBarcode *)barcode;

@end
