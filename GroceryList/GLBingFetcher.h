//
//  GLBingFetcher.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/7/15.
//
//

#import <Foundation/Foundation.h>

@class GLBarcodeObject;
@class RACSignal;
@class GLBingFetcher;
@class GLListObject;

@interface GLBingFetcher : NSObject

+ (GLBingFetcher *)sharedFetcher;

- (RACSignal *)fetchImageURLFromBingForListItem:(GLListObject *)listItem;

@end
