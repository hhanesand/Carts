//
//  AppDelegate.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.

#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <PubNub/PNImports.h>

#import "CAListTableViewController.h"
#import "AppDelegate.h"

#import "UIColor+CAColor.h"
#import "CAListObject.h"
#import "CABarcodeObject.h"
#import "CAListItemObject.h"
#import "CAListOverviewTableViewController.h"

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
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    [PubNub setDelegate:self];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)registerParseSubclasses {
    [CAListObject registerSubclass];
    [CAListItemObject registerSubclass];
    [CABarcodeObject registerSubclass];
}

- (void)initializeParseWithLaunchOptions:(NSDictionary *)launchOptions {
    [Parse enableLocalDatastore];
    [ParseCrashReporting enable];
    
    [Parse setApplicationId:@"LRHlZsMabq1sPNQ5UIu6PBS2jQ6VXLdGBCQREGmA" clientKey:@"aQRJaky1ooiD2xu7feLPvZjuwBXLNq7oDYsFdicl"];
    
    [PFTwitterUtils initializeWithConsumerKey:@"w7nv34kWb2UcCqurmS1SOUV4K" consumerSecret:@"q1uyBP2y42HDyuZZvIVZUqNkprcvYlzj2BqvT4wfl9heE3XV8M"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    [PFUser enableAutomaticUser];
}

- (void)prepareViewHeirarchy {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    CAListOverviewTableViewController *listOverviewTableViewController = [CAListOverviewTableViewController instance];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listOverviewTableViewController];
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
    [FBSDKAppEvents activateApp];
}

@end
