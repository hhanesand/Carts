//
//  AppDelgate.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import Foundation
import UIKit

@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate {
    
    var window : UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        //    [[ISKIssueManager defaultManager] setupWithReponame:@"hhanesand/Carts" andAccessToken:@"4e21dd278a7398cf30ed06fb1cfbe1859807cbc9"];
        //    [[ISKIssueManager defaultManager] setupImageUploadsWithClientID:@"f68d614e1112b70"];
        
        self.registerParseSubclasses()
        self.initializeParseWithLaunchOptions(launchOptions)
        self.prepareViewHeirarchy()
        
        if application.applicationState != .Background {
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !application.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            let noPushPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] == nil
            
            if preBackgroundPush || oldPushHandlerOnly || noPushPayload {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        let userNotificationTypes : UIUserNotificationType = (.Alert | .Badge | .Sound)
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.channels = ["global"]
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        
        if application.applicationState == .Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == .Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    func registerParseSubclasses() {
        CAListObject.registerSubclass()
        CAListItemObject.registerSubclass()
        CABarcodeObject.registerSubclass()
    }
    
    func initializeParseWithLaunchOptions(launchOptions: [NSObject : AnyObject]?) {
        Parse.enableLocalDatastore()
        ParseCrashReporting.enable()
        
        Parse.setApplicationId("LRHlZsMabq1sPNQ5UIu6PBS2jQ6VXLdGBCQREGmA", clientKey: "aQRJaky1ooiD2xu7feLPvZjuwBXLNq7oDYsFdicl");
        
        PFTwitterUtils.initializeWithConsumerKey("w7nv34kWb2UcCqurmS1SOUV4K", consumerSecret: "q1uyBP2y42HDyuZZvIVZUqNkprcvYlzj2BqvT4wfl9heE3XV8M")
        
        if (launchOptions != nil) {
            PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions!)
        }
        
        PFUser.enableAutomaticUser()
    }
    
    func prepareViewHeirarchy() {
//        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        let listOverviewTableViewController = CAListOverviewTableViewController.instance()
//        let navigationController = UINavigationController(rootViewController: listOverviewTableViewController)
//        self.window?.rootViewController = navigationController
//        
//        self.window?.makeKeyAndVisible()
        
        let manager = CAFactualSessionManager()
        manager.qu
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        let installation = PFInstallation.currentInstallation()
        
        if installation.badge != 0 {
            installation.badge = 0
            installation.saveEventually()
        }
        
        FBSDKAppEvents.activateApp()
    }
}