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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse enableLocalDatastore];
    [ParseCrashReporting enable];
    [Parse setApplicationId:@"LRHlZsMabq1sPNQ5UIu6PBS2jQ6VXLdGBCQREGmA" clientKey:@"aQRJaky1ooiD2xu7feLPvZjuwBXLNq7oDYsFdicl"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    if ([PFUser currentUser] == nil) {
        NSLog(@"Logging in");
        [PFUser logInWithUsername:@"lightice11" password:@"qwerty"];
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    GLTableViewController *itemsTableViewController = [[GLTableViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:itemsTableViewController];
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
