//
//  GLBarcodeDatabase.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

@import Foundation;
@class GLBarcodeManager;

@interface GLBarcodeDatabase : NSObject

@property (nonatomic) NSString *url;
@property (nonatomic) NSString *path;
@property (nonatomic) NSString *name;

//the path is the keypath to the name of the object in JSON
- (instancetype)initWithURLOfDatabase:(NSString *)url withName:(NSString *)name andPath:(NSString *)path;

- (NSString *)getURLForDatabaseWithBarcode:(NSString *)barcode;

@end