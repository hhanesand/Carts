//
//  GLScannerWrapperViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/25/15.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "GLBarcodeScannerDelegate.h"

@interface GLScannerWrapperViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic) id<GLBarcodeScannerDelegate> delegate;

- (void)stopScanning;
- (void)startScanning;

@end
