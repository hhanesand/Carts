//
//  PFQueryTableViewController+GLMutableTableView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/14/15.
//
//

#import "PFQueryTableViewController+GLMutableTableView.h"

@interface PFQueryTableViewController () {
    NSMutableArray *_mutableObjects;
}
@end

@implementation PFQueryTableViewController (GLMutableTableView)

- (NSMutableArray *)getInternalObjects {
    NSLog(@"Internal objects : %@ and public comparison %@", _mutableObjects, self.objects);
    return _mutableObjects;
}

@end
