//
//  GLScannerViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.
//
//

#import <UIKit/UIKit.h>
#import "GLBarcodeScannerDelegate.h"
#import "GLBarcodeItemDelegate.h"
#import "GLBaseViewController.h"
#import "GLTweakObserver.h"

@class RACSubject;

@interface GLScannerViewController : GLBaseViewController <GLBarcodeScannerDelegate, GLTweakObserver>

@property (nonatomic) id<GLBarcodeItemDelegate> delegate;

@end
