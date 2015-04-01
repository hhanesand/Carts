//
//  GLScannerViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.
//
//

#import "GLBarcodeScannerDelegate.h"
#import "GLBarcodeItemDelegate.h"
#import "GLBaseViewController.h"
#import "GLDismissableViewDelegate.h"

@class GLItemConfirmationView;
@class RACSubject;

@interface GLScannerViewController : GLBaseViewController <GLBarcodeScannerDelegate, UITableViewDelegate, UITableViewDataSource, GLDismissableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;

@property (nonatomic) id<GLBarcodeItemDelegate> delegate;

@property (nonatomic) GLItemConfirmationView *confirmationView;

@end
