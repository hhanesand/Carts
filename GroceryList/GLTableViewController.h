//
//  GLTableViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import <UIKit/UIKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "GLBarcodeItemDelegate.h"
#import "SWTableViewCell.h"
#import "ScanditSDKOverlayController.h"

@interface GLTableViewController : UITableViewController <GLBarcodeItemDelegate, SWTableViewCellDelegate>

@end
