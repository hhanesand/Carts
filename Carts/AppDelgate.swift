//
//  AppDelgate.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import Foundation
import UIKit
import Firebase

@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate {
    
    var window : UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        FIRApp.configure()
        
        //    [[ISKIssueManager defaultManager] setupWithReponame:@"hhanesand/Carts" andAccessToken:@"4e21dd278a7398cf30ed06fb1cfbe1859807cbc9"];
        //    [[ISKIssueManager defaultManager] setupImageUploadsWithClientID:@"f68d614e1112b70"];
        
        self.prepareViewHeirarchy()
        
        let userNotificationTypes : UIUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func prepareViewHeirarchy() {
//        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        let listOverviewTableViewController = CAListOverviewTableViewController.instance()
//        let navigationController = UINavigationController(rootViewController: listOverviewTableViewController)
//        self.window?.rootViewController = navigationController
//        
//        self.window?.makeKeyAndVisible()
    }
}