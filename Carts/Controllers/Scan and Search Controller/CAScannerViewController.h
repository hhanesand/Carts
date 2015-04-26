//
//  CAScannerViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.

#import "CABaseViewController.h"
#import "CADismissableViewHandler.h"
#import "CAKeyboardResponderAnimator.h"

@class CAManualEntryView;
@class RACSubject;

/**
 *  The view controller that handles barcode searching, scanning and networking with Factual
 */
@interface CAScannerViewController : CABaseViewController <CADismissableHandlerDelegate, CAKeyboardMovementResponderDelegate, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, UITextFieldDelegate>

+ (instancetype)instance;

/**
 *  A new CAListItem is sent on this signal when the user scans or entered a new item and it has been processed by the server
 */
@property (nonatomic) RACSignal *listItemSignal;

@end
