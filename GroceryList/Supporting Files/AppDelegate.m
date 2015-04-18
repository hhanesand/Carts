//
//  AppDelegate.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.

#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>

#import "GLTableViewController.h"
#import "AppDelegate.h"

#import "UIColor+GLColor.h"
#import "GLListObject.h"
#import "GLBarcodeObject.h"
#import "GLUser.h"

extern CFAbsoluteTime startTime;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Launched in %f sec", CFAbsoluteTimeGetCurrent() - startTime);
    });
    
    [Parse enableLocalDatastore];
    [ParseCrashReporting enable];
    [Parse setApplicationId:@"LRHlZsMabq1sPNQ5UIu6PBS2jQ6VXLdGBCQREGmA" clientKey:@"aQRJaky1ooiD2xu7feLPvZjuwBXLNq7oDYsFdicl"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [GLListObject registerSubclass];
    [GLBarcodeObject registerSubclass];
//    [GLUser registerSubclass];

    if ([PFUser currentUser] == nil) {
        NSLog(@"Logging in");
        [PFUser logInWithUsername:@"lightice11" password:@"qwerty"];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    GLTableViewController *itemsTableViewController = [[GLTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:itemsTableViewController];
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
