//
//  GLScannerViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.
//
//

#import <UIKit/UIKit.h>
#import "ScanditSDKOverlayController.h"
#import "GLBarcodeItemDelegate.h"

@interface GLScannerViewController : ScanditSDKBarcodePicker <ScanditSDKOverlayControllerDelegate>

@property (nonatomic) id<GLBarcodeItemDelegate> delegate;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@end
