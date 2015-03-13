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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse enableLocalDatastore];
    [ParseCrashReporting enable];
    [Parse setApplicationId:@"LRHlZsMabq1sPNQ5UIu6PBS2jQ6VXLdGBCQREGmA" clientKey:@"aQRJaky1ooiD2xu7feLPvZjuwBXLNq7oDYsFdicl"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [[UINavigationBar appearance] setBackgroundImage:[UIColor imageWithColor:[UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1]] forBarMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setBackgroundImage:[UIColor imageWithColor:[UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1]] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    #warning blocking
    if ([PFUser currentUser] == nil) {
        NSLog(@"Logging in");
        [PFUser logInWithUsername:@"lightice11" password:@"qwerty"];
    }
    
    self.window = [[GLTweakWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setTintColor:[UIColor whiteColor]];
    
    GLScannerViewController *scanner = [[GLScannerViewController alloc] init];
    self.window.rootViewController = scanner;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
