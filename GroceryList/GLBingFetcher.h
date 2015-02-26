//
//  GLBingFetcher.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/7/15.
//
//

#import <Foundation/Foundation.h>

@class GLBarcodeItem;
@class RACSignal;
@class GLBingFetcher;
@class GLListItem;

@interface GLBingFetcher : NSObject

+ (GLBingFetcher *)sharedFetcher;

- (RACSignal *)fetchImageURLFromBingForListItem:(GLListItem *)listItem;

@end
