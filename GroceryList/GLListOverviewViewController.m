//
//  GLListOverviewViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/18/15.

#import "GLListOverviewViewController.h"
#import "GLListObject.h"
#import "GLUser.h"

@implementation GLListOverviewViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.paginationEnabled = NO;
        self.loadingViewEnabled = NO;
        self.pullToRefreshEnabled = YES;
    }
    
    return self;
}

- (PFQuery *)queryForTable {
    return [[GLUser currentUser].following query];
}

@end