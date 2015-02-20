//
//  GLBingFetcher.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/7/15.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "GLBarcodeItem.h"
#import "GLListItem.h"

@class RACSignal;

@interface GLBingFetcher : NSObject

+ (GLBingFetcher *)sharedFetcher;

- (RACSignal *)fetchImageURLFromBingForListItem:(GLListItem *)listItem;

@end
