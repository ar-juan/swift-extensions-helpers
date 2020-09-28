//
//  AppDelegate.swift
//
//  Created by Arjan on 06/04/16.
//

import UIKit


extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager.sharedInstance().application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationManager.sharedInstance().application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    // MARK: remote notification preparation
    func prepareForNotificationsOfApplication(_ application: UIApplication) {
        print("call this via a manager, see `NotificationManager.swift`")
    }
    // MARK: Remote notification handling
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationManager.sharedInstance().application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NotificationManager.sharedInstance().userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }
}
//
//extension AppDelegate {
//
//    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) { // ONLY iOS 8+
//        NotificationManager.sharedInstance.application(application, didRegisterUserNotificationSettings: notificationSettings)
//    }
//    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) { // ONLY iOS 8+
//        NotificationManager.sharedInstance.application(application, handleActionWithIdentifier: identifier, forLocalNotification: notification, completionHandler: completionHandler)
//    }
//    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) { // ONLY iOS 8+
//        NotificationManager.sharedInstance.application(application, handleActionWithIdentifier: identifier, forRemoteNotification: userInfo, completionHandler: completionHandler)
//    }
//
//    // iOS 7+
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        NotificationManager.sharedInstance.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
//    }
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        NotificationManager.sharedInstance.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
//    }
//
//
//    // MARK: remote notification preparation
//    func prepareForNotificationsOfApplication(_ application: UIApplication) {
//        logthis("call this via a manager, see `NotificationManager.swift`")
//    }
//
//    // MARK: Remote notification handling
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        NotificationManager.sharedInstance.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
//    }
//
//    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
//        NotificationManager.sharedInstance.application(application, didReceiveLocalNotification: notification)
//    }
//}
