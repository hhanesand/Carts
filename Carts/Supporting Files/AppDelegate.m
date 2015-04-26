//
//  AppDelegate.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.

#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "GLListTableViewController.h"
#import "AppDelegate.h"

#import "UIColor+GLColor.h"
#import "GLListObject.h"
#import "GLBarcodeObject.h"
#import "GLListItemObject.h"
#import "GLListOverviewTableViewController.h"

extern CFTimeInterval startTime;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Launched in %f sec", CACurrentMediaTime() - startTime);
        NSLog(@"Bundle Identifier %@", [[NSBundle mainBundle] bundleIdentifier]);
    });
    
    [self registerParseSubclasses];
    [self initializeParseWithLaunchOptions:launchOptions];
    [self prepareViewHeirarchy];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];;
}

- (void)registerParseSubclasses {
    [GLListObject registerSubclass];
    [GLListItemObject registerSubclass];
    [GLBarcodeObject registerSubclass];
}

- (void)initializeParseWithLaunchOptions:(NSDictionary *)launchOptions {
    [Parse enableLocalDatastore];
    [ParseCrashReporting enable];
    
    [Parse setApplicationId:@"LRHlZsMabq1sPNQ5UIu6PBS2jQ6VXLdGBCQREGmA" clientKey:@"aQRJaky1ooiD2xu7feLPvZjuwBXLNq7oDYsFdicl"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFTwitterUtils initializeWithConsumerKey:@"w7nv34kWb2UcCqurmS1SOUV4K" consumerSecret:@"q1uyBP2y42HDyuZZvIVZUqNkprcvYlzj2BqvT4wfl9heE3XV8M"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    [PFUser enableAutomaticUser];
}

- (void)prepareViewHeirarchy {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    GLListOverviewTableViewController *listOverviewTableViewController = [GLListOverviewTableViewController instance];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listOverviewTableViewController];
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

@end
