//
//  GLTableViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import "GLBarcodeItemDelegate.h"
#import "GLTweakObserver.h"
#import "GLQueryTableViewController.h"
#import "GLBaseViewController.h"

@class RACSignal;

@interface GLTableViewController : GLQueryTableViewController <GLBarcodeItemDelegate, GLTweakObserver, UIViewControllerTransitioningDelegate>

@end
