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
#import "GLQueryTableViewController.h"
#import "GLBaseViewController.h"

@class RACSignal;

@interface GLTableViewController : GLQueryTableViewController<GLBarcodeItemDelegate, GLTweakObserver>

@property (nonatomic, weak) GLBaseViewController *transitionDelegate;

@property (nonatomic) RACSubject *addItemSignal;

@end
