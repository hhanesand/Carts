//
//  GLScannerViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.

#import "GLBaseViewController.h"
#import "GLDismissableViewHandler.h"
#import "GLKeyboardResponderAnimator.h"

@class GLManualEntryView;
@class RACSubject;

/**
 *  The view controller that handles barcode searching, scanning and networking with Factual
 */
@interface GLScannerViewController : GLBaseViewController <GLDismissableHandlerDelegate, GLKeyboardMovementResponderDelegate, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, UITextFieldDelegate>

+ (instancetype)instance;

/**
 *  A new GLListItem is sent on this signal when the user scans or entered a new item and it has been processed by the server
 */
@property (nonatomic) RACSignal *listItemSignal;

@end
