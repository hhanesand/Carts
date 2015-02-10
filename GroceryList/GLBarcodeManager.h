//
//  GLBarcodeManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import <Foundation/Foundation.h>
#import "GLBarcodeDatabase.h"
#import "ReactiveCocoa/ReactiveCocoa.h"

@interface GLBarcodeManager : NSObject

@property (nonatomic) RACSubject *barcodeItemSignal;
@property (nonatomic) NSString *notification;

- (void)addBarcodeDatabase:(GLBarcodeDatabase *)database;

- (void)fetchNameOfItemWithBarcode:(NSString *)barcode;

@end
