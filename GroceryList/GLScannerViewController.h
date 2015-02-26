//
//  GLScannerViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.
//
//

#import <UIKit/UIKit.h>
#import "GLBarcodeItemDelegate.h"
#import "GLBarcodeScannerDelegate.h"

@interface GLScannerViewController : UIViewController <GLBarcodeScannerDelegate>

@property (nonatomic) id<GLBarcodeItemDelegate> delegate;

@end
