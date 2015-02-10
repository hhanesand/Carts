//
//  GLBarcodeItem.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/9/15.
//
//

#import <Foundation/Foundation.h>
#import "GLBarcodeItemDelegate.h"

@interface GLBarcodeItem : NSObject

@property (nonatomic) id<GLBarcodeItemDelegate> delegate;

@property (nonatomic) NSString *barcode;
@property (nonatomic) NSString *name;
@property (nonatomic) NSData *imageData;

- (instancetype)initWithBarcode:(NSString *)barcode name:(NSString *)name;
- (instancetype)initWithBarcode:(NSString *)barcode name:(NSString *)name andPictureURL:(NSString *)url;

@end