//
//  GLTableViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "GLBarcodeItemDelegate.h"

@interface GLTableViewController : UITableViewController <ZBarReaderDelegate, GLBarcodeItemDelegate>

- (void)didFinishLoadingImageForBarcodeItem:(GLBarcodeItem *)barcodeItem;

@end
