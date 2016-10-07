//
//  AppDelegate.swift
//  HackathonBase
//
//  Created by Sihao Lu, Vincent Yan on 9/10/15.
//  Copyright © 2015 Sihao Lu, Vincent Yan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import CloudKit

let RemoteNotificationReceivedNotification = "RemoteReceived"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        if launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] != nil {
            ShareManager.sharedInstance.shouldHandlePushNotification = true
            NSNotificationCenter.defaultCenter().postNotificationName(RemoteNotificationReceivedNotification, object: self)
        }
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        resetBadgeCounter()
        return true
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        let notification = CKNotification(fromRemoteNotificationDictionary: (userInfo as! [String: NSObject]))
        ShareManager.sharedInstance.shouldHandlePushNotification = true
        NSNotificationCenter.defaultCenter().postNotificationName(RemoteNotificationReceivedNotification, object: self)
    }
    
    func resetBadgeCounter() {
        let badgeResetOperation = CKModifyBadgeOperation(badgeValue: 0)
        badgeResetOperation.modifyBadgeCompletionBlock = { (error) -> Void in
            if error != nil {
                print("Error resetting badge: \(error)")
            } else {
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
        }
        CKContainer.defaultContainer().addOperation(badgeResetOperation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        if UIApplication.sharedApplication().applicationIconBadgeNumber != 0 {
            ShareManager.sharedInstance.shouldHandlePushNotification = true
            NSNotificationCenter.defaultCenter().postNotificationName(RemoteNotificationReceivedNotification, object: self)
        }
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        resetBadgeCounter()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

