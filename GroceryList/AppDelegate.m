//
//  AppDelegate.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import "UIColor+GLColor.h"
#import "GLTweakWindow.h"
#import "GLScannerViewController.h"
#import "GLTableViewController.h"
#import "GLTransitionManager.h"
#import "GLTransition.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse enableLocalDatastore];
    [ParseCrashReporting enable];
    [Parse setApplicationId:@"LRHlZsMabq1sPNQ5UIu6PBS2jQ6VXLdGBCQREGmA" clientKey:@"aQRJaky1ooiD2xu7feLPvZjuwBXLNq7oDYsFdicl"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    #warning blocking
    if ([PFUser currentUser] == nil) {
        NSLog(@"Logging in");
        [PFUser logInWithUsername:@"lightice11" password:@"qwerty"];
    }
    
    self.window = [[GLTweakWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = viewController;
    GLTransitionManager *manager = [[GLTransitionManager alloc] initWithRootWindow:self.window];
    [GLTransitionManager setSharedInstance:manager];
    
    GLTableViewController *tableViewController = [[GLTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    [[GLTransitionManager sharedInstance] pushViewController:nav withAnimation:[GLTransition transition]];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
