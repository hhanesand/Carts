//
//  GLBarcodeItem.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/9/15.
//
//

#import <Foundation/Foundation.h>

@interface GLBarcodeItem : NSObject

@property (nonatomic) NSString *barcode;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *url;

- (instancetype)initWithBarcode:(NSString *)barcode name:(NSString *)name;
- (instancetype)initWithBarcode:(NSString *)barcode name:(NSString *)name andPictureURL:(NSString *)url;

- (NSURL *)getURLForPicture;

@end