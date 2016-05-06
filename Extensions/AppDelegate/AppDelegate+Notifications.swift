//
//  AppDelegate.swift
//
//  Created by Arjan on 06/04/16.
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
    
    // MARK: Remote notification handling
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        NotificationManager.sharedInstance.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NotificationManager.sharedInstance.application(application, didReceiveLocalNotification: notification)
    }
}

extension AppDelegate { // Notifications
//    // NOTE: implement in AppDelegate.swift:
//    
//    //var shouldRegisterForRemoteNotifications = ?
//    //var shouldRegisterForUserNotifications = ?
//    // func preparedForNotification(token: String)
////    // Example:
////    func preparedForNotifications(token token: String) { // may be called multiple times
////        if shouldRegisterForRemoteNotifications &&
////            shouldRegisterForUserNotifications &&
////            NotificationManager.properties.registeredForUserNotifications &&
////            NotificationManager.properties.registeredForRemoteSilentTypeNotifications {
////            UserDefaults.NotificationDeviceToken = token
////        } else if shouldRegisterForUserNotifications &&
////            NotificationManager.properties.registeredForUserNotifications {
////            UserDefaults.NotificationDeviceToken = token
////        }
////    }
//    
//    struct properties { // NOTE: Expects only one AppDelegate!!
//        static var deviceToken: NSData?
//        static var registeredForUserNotifications: Bool = false
//        static var registeredForRemoteSilentTypeNotifications: Bool = false
//        static var iOS8AndHigherNotificationSettings: UIUserNotificationType = UIUserNotificationType.Alert.union(UIUserNotificationType.Badge).union(UIUserNotificationType.Sound)
//        static var iOS7AndLowerNotificationSettings: UIRemoteNotificationType = UIRemoteNotificationType.Alert.union(UIRemoteNotificationType.Badge.union(UIRemoteNotificationType.Sound))
//        
//        /**
//         If we get a remote notification, we have a short time to do stuff, and then we have to call the completion handler.
//         If we fail to to it quickly, we might never be able to. Therefore we keep a timer that executes the completion handler anyways.
//         */
//        static var didReceiveRemoteNotificationFetchCompletionHandlerTimer: NSTimer?
//        
//        /**
//         If we get a remote notification, we have a short time to do stuff, and then we have to call the completion handler.
//         We save it during that time.
//         */
//        static var didReceiveRemoteNotificationFetchCompletionHandler: ((UIBackgroundFetchResult) -> Void)? {
//            didSet {
//                // in case FetchCompletionHandler is not called by the app, call it anyways
//                didReceiveRemoteNotificationFetchCompletionHandlerTimer = NSTimer(timeInterval: 10, target: UIApplication.sharedApplication().delegate! /* == self */, selector: #selector(AppDelegate.runDidReceiveRemoteNotificationFetchCompletionHandlerIfFailed(_:)), userInfo: nil, repeats: false)
//            }
//        }
//    }
//    
//    // MARK: remote notification preparation
//    
//    /**
//     This function prepares the application for receiving notifications.
//     - Requires: a NotificationManager.sharedinstance.delegate object to return the result (token) to
//     - Parameter shouldRegisterForRemoteNotifications: This is, depending a bit on the iOS version, to be set to `true` if remote push notifications (e.g. from a backend server) are to be send to the application
//     - parameter shouldRegisterForUserNotifications: This is, depending a bit on the iOS version, to be set to `true` if the user should be able te receive UI based, visible notifications on screen. Registering only for remote notifications doesnt also give permission to UI based notifications, but only for so called silent type notifications.
//     - Note: If shouldRegisterForRemoteNotifications == true, shouldRegisterForUserNotifications should also be true
//     - Returns: Nothing, but when the preparation is complete, delegate?.prepared(token:) will be called to notify of the token.
//     */
//    func prepareForNotificationsOfApplication(application: UIApplication, shouldRegisterForRemoteNotifications: Bool, shouldRegisterForUserNotifications: Bool) {
//        self.shouldRegisterForRemoteNotifications = shouldRegisterForRemoteNotifications
//        self.shouldRegisterForUserNotifications = shouldRegisterForUserNotifications
//        if shouldRegisterForRemoteNotifications {
//            self.shouldRegisterForUserNotifications = true
//        }
//        
//        if application.respondsToSelector(#selector(UIApplication.registerForRemoteNotifications)) { // iOS 8+
//            // in case of ios 8, besides registerForRemoteNotifications, also request
//            // permission for remote and local user notifs (UI-based)
//            // which has its own callback method didRegisterUserNotificationSettings,
//            // so we save the deviceToken until the callback
//            if shouldRegisterForUserNotifications {
//                if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) { //iOS 8+
//                    let settings = UIUserNotificationSettings(forTypes: properties.iOS8AndHigherNotificationSettings, categories: nil)
//                    application.registerUserNotificationSettings(settings)
//                    // If you do not call this method, the system delivers all remote notifications to your app silently.
//                }
//            }
//            
//            // from ios 8, remote silent notifs and remote and local user notifs are seperated.
//            // remote silent notifs are enabled by default (as long as your app has the Capability)
//            // and you called registerForRemoteNotifications once
//            // (although it can still be disabled in the settings)
//            // you still need to call below code though, to get the token
//            if shouldRegisterForRemoteNotifications {
//                application.registerForRemoteNotifications()
//            }
//            // this either calls didRegistForRemoteNotificationsWithDeviceToken:, or
//            // or calls didFailToRegisterForRemoteNotificationsWithError:
//            /* in ios 8: If you want your app’s remote (and local) notifications to
//             display alerts, play sounds, or perform other user-facing actions, you must
//             call the registerUserNotificationSettings: method to request the types of
//             notifications you want to use. If you do not call that method, the system
//             delivers all remote notifications to your app silently. */
//        } else { // iOS 7
//            // In ios 7, remote silent and user notifs are handled the same way in terms of permission
//            if shouldRegisterForUserNotifications || shouldRegisterForRemoteNotifications {
//                let types: UIRemoteNotificationType = properties.iOS7AndLowerNotificationSettings
//                application.registerForRemoteNotificationTypes(types)
//            }
//        }
//    }
//    
//    
//    // MARK: Remote Notification Registration delegate methods
//    /**
//     To use UserNotificationActions you need to
//     - Register the actions (UIUserNotificationAction), categories (UIUSerNotificationCategory), and settings (UIUSerNotificationSettings)
//     - Push (remote) / schedule (local) the notification:
//     aps { alert: {...}, cateory: "INVITE" }
//     notification.category = @"INVITE"
//     - Handle the action: handleActionWithIdentifier
//     
//     
//     There's 2 typs of remote notification:
//     User Notifs: APN server sending aps {alert: {...} } resulting in the user notification being presented to the user
//     Silent type Notifs: APNs server sending push notif with the content-available flag in it: aps { content-available: 1 }
//     instead of providing a user interface notif,
//     */
//    // remote AND local
//    // iOS 8+
//    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) { // ONLY iOS 8+
//        properties.registeredForUserNotifications = true
//        if var tokenString: String = properties.deviceToken?.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")) {
//            tokenString = tokenString.stringByReplacingOccurrencesOfString(" ", withString: "")
//            preparedForNotifications(token: tokenString)
//            //UserDefaults.NotificationDeviceToken = tokenString
//        } else {
//            // there's no token yet. In case the user said NO, it will never come
//        }
//        
//        // User has allowed receiving the following types:
//        //let allowedTypes: UIUserNotificationType = notificationSettings.types
//        
//        //if !allowedTypes.contains(UIUserNotificationType.Alert) { doSomething }
//        // kan geimplementeerd worden als bijv. delegate?.whatToDoWithAllowedTypes(allowedTypes: allowedTypes)
//    }
//    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) { // ONLY iOS 8+
//        // identifier: you can use this to determine what action was tapped on
//        // e.g. if (identifier isEqualToString:@"ACCEPT_IDENTIFIER"): [self handleAcceptNotif];
//    }
//    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) { // ONLY iOS 8+
//        // idem maar voor remote notifs
//    }
//    
//    // iOS 7+
//    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) { // iOS 7 also (maybe even lower)
//        // Meaning in ios 7: registered for requested types of remote user AND silent types notifications
//        // Meaning in ios 8+: registered only for remote silent type notifications.
//        
//        // note that the delegate method may be called any time the device token changes,
//        // not just in response to your app registering or re-registering
//        
//        // in ios 8: If you want your app’s remote (and local) notifications to display alerts, play sounds, or perform other user-facing actions, you must call the registerUserNotificationSettings: method to request the types of notifications you want to use. If you do not call that method, the system delivers all remote notifications to your app silently.
//        
//        // Set property for later use
//        properties.registeredForRemoteSilentTypeNotifications = true
//        
//        // in ios 7 there is no distinction between silent type and user notifs, so we can set the token and we're done
//        if UIDevice.currentDevice().iOSVersion >= 7 && UIDevice.currentDevice().iOSVersion < 8 {
//            properties.registeredForUserNotifications = true
//            if var tokenString: String = properties.deviceToken?.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")) {
//                tokenString = tokenString.stringByReplacingOccurrencesOfString(" ", withString: "")
//                preparedForNotifications(token: tokenString)
//
//            }
//        } else {
//            // in case of ios 8, we also request permission for (remote and local) user notifs (UI-based)
//            // which has its own callback method didRegisterUserNotificationSettings,
//            // so we save the deviceToken until the callback unless we're past that stage already
//            
//            // so if didRegisterUserNotificationSettings was already called
//            if properties.registeredForUserNotifications == true {
//                // save the token to UserDefaults
//                var tokenString = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
//                tokenString = tokenString.stringByReplacingOccurrencesOfString(" ", withString: "")
//                preparedForNotifications(token: tokenString)
//
//                //UserDefaults.NotificationDeviceToken = tokenString
//            } else {
//                // didRegisterUserNotificationSettings still has to be called (but might never)
//                // TODO might never
//                properties.deviceToken = deviceToken;
//            }
//        }
//        /*
//         Note:
//         Token uniquely identifies device, but is not the same as UDID
//         It may change: hence, call registration API on every launch, and dont depend on cached copy of it
//         */
//    }
//    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
//        // Meaning in ios 7: registration for requested types of (remote) user AND silent types notifications failed.
//        // Meaning in ios 8: registration for remote silent type notifications failed.
//        
//        // Warning: this is not called if the user doesnt allow the app to deliver remote notifs!
//        // In that case, didRegisterForRemoteNotificationsWithDeviceToken is simply not called
//        
//        // Although, just in case:
//        properties.registeredForRemoteSilentTypeNotifications = false
//        properties.registeredForUserNotifications = false
//        
//        print("application:didFailToRegisterForRemoteNotificationsWithError says: \(error.localizedDescription)")
//        //[[AlertManager sharedManager] showNotificationErrorAlert]; // dont show error just yet, in ios 8 this means only that registration for remote silent type notifications failed. Could happen if we're in airplane mode while requesting it?
//        
//        print("application:didFailToRegisterForRemoteNotificationsWithError says: Check your provisioning profile for entitlements --> this means you need a provisioning profile in which the capability \"Remote notifications\" is checked. Once you did that, you also need to add a APNs certificate for development and production connected to the App Id of this app. Also note that push is not supported in the ios simulator")
//    }
//    
//    
//    // MARK: remote notification fetch completion handler
//    func runDidReceiveRemoteNotificationFetchCompletionHandler() {
//        // If we're gonna call the completion handler, then we're at a point in time BEFORE the timer expired, so we
//        // don't need that timer anymore.
//        if properties.didReceiveRemoteNotificationFetchCompletionHandlerTimer != nil {
//            properties.didReceiveRemoteNotificationFetchCompletionHandlerTimer?.invalidate()
//            properties.didReceiveRemoteNotificationFetchCompletionHandlerTimer = nil
//        }
//        
//        // store the completionHandler locally first
//        if let completionHandler: ((UIBackgroundFetchResult) -> Void)? = properties.didReceiveRemoteNotificationFetchCompletionHandler {
//            // so we can nillify it, preventing it from being called more than once
//            properties.didReceiveRemoteNotificationFetchCompletionHandler = nil
//            
//            print("calling completionhandler didReceiveRemoteNotificationFetch")
//            completionHandler?(UIBackgroundFetchResult.NewData)
//        }
//    }
//    func runDidReceiveRemoteNotificationFetchCompletionHandlerIfFailed(timer: NSTimer?) {
//        // If we're gonna call the completion handler, then we're at a point in time AT the timer expired, so we
//        // don't need that timer anymore.
//        if properties.didReceiveRemoteNotificationFetchCompletionHandlerTimer != nil {
//            print("failed to call remote notif completion handler before 10 seconds")
//            properties.didReceiveRemoteNotificationFetchCompletionHandlerTimer?.invalidate()
//            properties.didReceiveRemoteNotificationFetchCompletionHandlerTimer = nil
//        }
//        
//        if let completionHandler: ((UIBackgroundFetchResult) -> Void)? = properties.didReceiveRemoteNotificationFetchCompletionHandler {
//            print("calling completionhandler didReceiveRemoteNotificationFetch based on timer")
//            completionHandler?(UIBackgroundFetchResult.Failed)
//        }
//    }
}