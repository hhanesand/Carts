//
//  GLBarcodeItemDelegate.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/2/15.
//
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@protocol GLBarcodeItemDelegate <NSObject>
@required
@property (nonatomic) RACSignal *barcodeSignal;
@end
