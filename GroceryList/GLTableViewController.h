//
//  GLTableViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import "PFQueryTableViewController.h"
#import "GLBarcodeItemDelegate.h"
#import "GLTweakObserver.h"
#import <Tweaks/FBTweak.h>

@interface GLTableViewController : PFQueryTableViewController<GLBarcodeItemDelegate, GLTweakObserver>

@end
