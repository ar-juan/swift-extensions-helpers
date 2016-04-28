//
//  AppDelegate.swift
//  Jeeves
//
//  Created by Arjan on 06/04/16.
//  Copyright © 2016 Auxilium. All rights reserved.
//

import UIKit

extension AppDelegate {
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) { // ONLY iOS 8+
        NotificationManager.sharedInstance.application(application, didRegisterUserNotificationSettings: notificationSettings)
    }
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) { // ONLY iOS 8+
        NotificationManager.sharedInstance.application(application, handleActionWithIdentifier: identifier, forLocalNotification: notification, completionHandler: completionHandler)
    }
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) { // ONLY iOS 8+
        NotificationManager.sharedInstance.application(application, handleActionWithIdentifier: identifier, forRemoteNotification: userInfo, completionHandler: completionHandler)
    }
    
    // iOS 7+
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        NotificationManager.sharedInstance.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NotificationManager.sharedInstance.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    
    // MARK: remote notification preparation
    func prepareForNotificationsOfApplication(application: UIApplication) {
        logthis("call this via a manager, see `NotificationManager.swift`")
    }
    
    // MARK: remote notification fetch completion handler
    func runDidReceiveRemoteNotificationFetchCompletionHandler() {
        NotificationManager.sharedInstance.runDidReceiveRemoteNotificationFetchCompletionHandler()
    }
    
    func runDidReceiveRemoteNotificationFetchCompletionHandlerIfFailed(timer: NSTimer?) {
        NotificationManager.sharedInstance.runDidReceiveRemoteNotificationFetchCompletionHandlerIfFailed(timer)
    }
}