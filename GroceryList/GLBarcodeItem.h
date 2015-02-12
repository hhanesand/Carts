//
//  GLBarcodeItem.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/9/15.
//
//

#import <Foundation/Foundation.h>
#import "GLBarcodeItemDelegate.h"
#import "Parse/Parse.h"

@interface GLBarcodeItem : PFObject<PFSubclassing>

@property (nonatomic) id<GLBarcodeItemDelegate> delegate;

@property (nonatomic) NSString *barcode;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *url;

@property (nonatomic) NSData *imageData;

+ (NSString *)notificationName;
+ (NSString *)parseClassName;

- (instancetype)initWithBarcode:(NSString *)barcode name:(NSString *)name;

- (void)fetchPictureWithURL:(NSURL *)url;

@end