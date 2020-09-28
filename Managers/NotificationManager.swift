//
//  NotificationManager.swift
//  App
//
//  Created by Arjan on 28/04/16.
//

import UIKit
import UserNotifications

///////////////////////////// Example implementation
/*
/**
 This app specific notification manager should be used as the central point for
 - registering the app for receiving notifications, both UI based and remote push notifications
 - showing a notification to the user
 In the appDelegate, you should call `AppNotificationManager.sharedInstance.prepareForApplication()`
 */
class AppNotificationManager: NotificationManagerDelegate {
    static let sharedInstance = AppNotificationManager()
    let manager = NotificationManager.sharedInstance()
    
    private init() {
        manager.delegate = self
    }
    
    // MARK: Preparation
    func prepareForApplication(application:UIApplication, shouldRegisterForRemoteNotifications: Bool, shouldRegisterForUserNotifications: Bool) {
        if shouldRegisterForRemoteNotifications {
            manager.shouldRegisterForUserNotifications = true
        }
        manager.prepareForNotificationsOfApplication(application, shouldRegisterForRemoteNotifications: shouldRegisterForRemoteNotifications, shouldRegisterForUserNotifications: shouldRegisterForUserNotifications)
    }
    
    func prepared(token: String) { // may be called multiple times
        if manager.shouldRegisterForRemoteNotifications &&
            manager.shouldRegisterForUserNotifications &&
            NotificationManager.properties.registeredForUserNotifications &&
            NotificationManager.properties.registeredForRemoteSilentTypeNotifications {
            Storage.pushIdentifier = token
        } else if manager.shouldRegisterForUserNotifications &&
            NotificationManager.properties.registeredForUserNotifications {
            Storage.pushIdentifier = token
        }
    }
    
    func handleRemoteNotificationWithUserInfo(_ userInfo: [AnyHashable : Any], whenDone completion: @escaping ((UIBackgroundFetchResult) -> Void)) {
        let result: UIBackgroundFetchResult = .noData
        completion(result)
    }
    
    func handleLocalNotification(_ notification: UNNotification) {
        let alert = UIAlertController(title: notification.request.content.title, message: notification.request.content.body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction) in
            // Do something
        }))
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: false, completion: nil)
    }
}
*/


protocol NotificationManagerDelegate {
    /**
     This function is called when there is a tokenstring available. If for one reason the app gets a new token, this will be called again. There needs to be a delegate troughout the lifetime of the `NotificationManager`.
     
     - parameter token: The notification token / identification of this specific app on this specific device
     */
    func prepared(token: String)
    
    /**
     This method is called when a remote (push) notification has been received by the device. The delegate needs to handle this remote notification.
     - parameter userInfo: a dictionary containing the notification data.
     - parameter whenDone: a closure that needs to be called within a finite amount of time (see `completionHandlerTimeout`) after receiving the remote notification. Failing to call this within the set amount of time may cause a delayed aflevering of future remote notifications. Therefore if the timer which we set, reaches that time limit, `NotificationManager` force-calls a completionhandler with result `UIBackgroundFetchResult.Failed` itself and the `whenDone` of this method will never be called.
     */
    func handleRemoteNotificationWithUserInfo(_ userInfo: [AnyHashable: Any], whenDone completion: @escaping ((UIBackgroundFetchResult)->Void))
    
    /**
     This method is called when a local (user) notification has been received by the device. The delegate needs to handle this local notification.
     `notification.userInfo` contains the data related to this `notification`
     */
    func handleLocalNotification(_ notification: UNNotification)
}
@objc class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    // like this the sharedInstance class method can be reached from ObjC.
    class func sharedInstance() -> NotificationManager {
        return NotificationManager._sharedInstance
    }
    static let _sharedInstance = NotificationManager() // Singleton pattern
    private override init() {} // prevents others from using the default '()' initializer for this class.
    var delegate: NotificationManagerDelegate?
    static let completionHandlerTimeout: TimeInterval = 10 // seconds

    var shouldRegisterForRemoteNotifications = true
    var shouldRegisterForUserNotifications = true
    
    struct properties { // Expects singleton pattern!!
        static var deviceToken: Data?
        static var registeredForUserNotifications: Bool = false
        static var registeredForRemoteSilentTypeNotifications: Bool = false

        static var notificationSettings: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        /**
         If we get a remote notification, we have a short time to do stuff, and then we have to call the completion handler.
         If we fail to to it quickly, we might never be able to. Therefore we keep a timer that executes the completion handler anyways.
         */
        static var didReceiveRemoteNotificationFetchCompletionHandlerTimer: Timer?
        
        /**
         If we get a remote notification, we have a short time to do stuff, and then we have to call the completion handler.
         We save it during that time.
         */
        static var didReceiveRemoteNotificationFetchCompletionHandler: ((UIBackgroundFetchResult) -> Void)? {
            didSet {
                // in case FetchCompletionHandler is not called by the app, call it anyways
                if (didReceiveRemoteNotificationFetchCompletionHandler != nil) {
                    didReceiveRemoteNotificationFetchCompletionHandlerTimer = Timer.scheduledTimer(timeInterval: completionHandlerTimeout, target: NotificationManager.sharedInstance, selector: #selector(NotificationManager.runDidReceiveRemoteNotificationFetchCompletionHandlerIfFailed(_:)), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    // MARK: remote notification preparation
 
    /**
     This function prepares the application for receiving notifications.
     - Requires: a NotificationManager.sharedinstance.delegate object to return the result (token) to
     - Parameter shouldRegisterForRemoteNotifications: This is, depending a bit on the iOS version, to be set to `true` if remote push notifications (e.g. from a backend server) are to be send to the application
     - parameter shouldRegisterForUserNotifications: This is, depending a bit on the iOS version, to be set to `true` if the user should be able te receive UI based, visible notifications on screen. Registering only for remote notifications doesnt also give permission to UI based notifications, but only for so called silent type notifications.
     - Note: If shouldRegisterForRemoteNotifications == true, shouldRegisterForUserNotifications should also be true
     - Returns: Nothing, but when the preparation is complete, delegate?.prepared(token:) will be called to notify of the token.
     */
    func prepareForNotificationsOfApplication(_ application: UIApplication, shouldRegisterForRemoteNotifications: Bool, shouldRegisterForUserNotifications: Bool) {
        self.shouldRegisterForRemoteNotifications = shouldRegisterForRemoteNotifications
        self.shouldRegisterForUserNotifications = shouldRegisterForUserNotifications
        if shouldRegisterForRemoteNotifications {
            self.shouldRegisterForUserNotifications = true // as well
        }

        if shouldRegisterForUserNotifications {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            
            center.requestAuthorization(options: properties.notificationSettings) { (granted, error) in
                guard error == nil else {
                    print("UNUserNotificationCenter requestAuthorization error: \(error!.localizedDescription)")
                    return
                }
                
                center.getNotificationSettings(completionHandler: { (unSettings: UNNotificationSettings) in
                    
                    var allowedTypes = UNAuthorizationOptions()
                    
                    if properties.notificationSettings.contains(.badge) && unSettings.badgeSetting == .enabled { allowedTypes.insert(.badge) }
                    if properties.notificationSettings.contains(.sound) && unSettings.soundSetting == .enabled { allowedTypes.insert(.sound) }
                    if properties.notificationSettings.contains(.alert) && unSettings.alertSetting == .enabled { allowedTypes.insert(.alert) }
                    
                    
                    /*
                     There's 2 typs of remote notification:
                     User Notifs: APN server sending aps {alert: {...} } resulting in the user notification being presented to the user
                     Silent type Notifs: APNs server sending push notif with the content-available flag in it: aps { content-available: 1 }
                     instead of providing a user interface notif,
                     */
                    
                    properties.registeredForUserNotifications = true
                    if properties.deviceToken != nil, let tokenString: String = String(data: properties.deviceToken!, encoding: .utf8) /*?.hexString*/ {
                        self.delegate?.prepared(token: tokenString)
                        if self.delegate == nil {
                            print("1 Did you forget to set the delegate of the NotificationManager (see example implementation on top of file)?")
                        }
                    } else {
                        // there's no token yet. In case the user said NO, it will never come
                    }
                    
                    if shouldRegisterForRemoteNotifications {
                        DispatchQueue.main.async {
                            application.registerForRemoteNotifications()
                        }
                    }
                    
                    //if !allowedTypes.contains(UIUserNotificationType.Alert) { doSomething }
                    // kan geimplementeerd worden als bijv. delegate?.whatToDoWithAllowedTypes(allowedTypes: allowedTypes)
                })
            }
        }

    }
    


    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        //
    }

    
    // MARK: Remote Notification Registration delegate methods
    /**
     To use UserNotificationActions you need to
     - Register the actions (UIUserNotificationAction), categories (UIUSerNotificationCategory), and settings (UIUSerNotificationSettings)
     - Push (remote) / schedule (local) the notification:
     aps { alert: {...}, cateory: "INVITE" }
     notification.category = @"INVITE"
     - Handle the action: handleActionWithIdentifier
     
     
     There's 2 typs of remote notification:
     User Notifs: APN server sending aps {alert: {...} } resulting in the user notification being presented to the user
     Silent type Notifs: APNs server sending push notif with the content-available flag in it: aps { content-available: 1 }
     instead of providing a user interface notif,
     */
    // remote AND local
    // iOS 8+
    func application(_ application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UNNotificationSettings) {
 
    }

    
    //
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Meaning in ios 8+: registered only for remote silent type notifications.
        
        // note that the delegate method may be called any time the device token changes,
        // not just in response to your app registering or re-registering
        
        // in ios 8: If you want your app’s remote (and local) notifications to display alerts, play sounds, or perform other user-facing actions, you must call the registerUserNotificationSettings: method to request the types of notifications you want to use. If you do not call that method, the system delivers all remote notifications to your app silently.
        
        // Set property for later use
        properties.registeredForRemoteSilentTypeNotifications = true
        
        // in case of ios 8, we also request permission for (remote and local) user notifs (UI-based)
        // which has its own callback method didRegisterUserNotificationSettings,
        // so we save the deviceToken until the callback unless we're past that stage already
        
        // so if didRegisterUserNotificationSettings was already called
        if properties.registeredForUserNotifications == true {
            // save the token to UserDefaults
            
            let tokenParts = deviceToken.map { data -> String in
                return String(format: "%02.2hhx", data)
            }
            let token = tokenParts.joined()
            print("Device Token: \(token)")
            
            delegate?.prepared(token: token)
            if delegate == nil {
                print("2 Did you forget to set the delegate of the NotificationManager (see example implementation on top of file)?")
            }
            //UserDefaults.NotificationDeviceToken = tokenString
        } else {
            // didRegisterUserNotificationSettings still has to be called (but might never)
            // so we save if for later
            // TODO might never
            properties.deviceToken = deviceToken;
        }
        
        /*
         Note:
         Token uniquely identifies device, but is not the same as UDID
         It may change: hence, call registration API on every launch, and dont depend on cached copy of it
         */
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Meaning in ios 8-9: registration for remote silent type notifications failed.
        
        // Warning: this is not called if the user doesnt allow the app to deliver remote notifs!
        // In that case, didRegisterForRemoteNotificationsWithDeviceToken is simply not called
        
        // Although, just in case:
        properties.registeredForRemoteSilentTypeNotifications = false
        properties.registeredForUserNotifications = false
        
        print("application:didFailToRegisterForRemoteNotificationsWithError says: \(error.localizedDescription)")
        //[[AlertManager sharedManager] showNotificationErrorAlert]; // dont show error just yet, in ios 8 this means only that registration for remote silent type notifications failed. Could happen if we're in airplane mode while requesting it?
        
        print("application:didFailToRegisterForRemoteNotificationsWithError says: Check your provisioning profile for entitlements --> this means you need a provisioning profile in which the capability \"Remote notifications\" is checked. Once you did that, you also need to add a APNs certificate for development and production connected to the App Id of this app. Also note that push is not supported in the ios simulator")
    }
    
    
    // MARK: remote notification fetch completion handler
    func runDidReceiveRemoteNotificationFetchCompletionHandler(_ result: UIBackgroundFetchResult) {
        // If we're gonna call the completion handler, then we're at a point in time BEFORE the timer expired, so we
        // don't need that timer anymore.
        if properties.didReceiveRemoteNotificationFetchCompletionHandlerTimer != nil {
            properties.didReceiveRemoteNotificationFetchCompletionHandlerTimer!.invalidate()
            properties.didReceiveRemoteNotificationFetchCompletionHandlerTimer = nil
        }
        
        // store the completionHandler locally first
        if let completionHandler: ((UIBackgroundFetchResult) -> Void) = properties.didReceiveRemoteNotificationFetchCompletionHandler {
            // so we can nillify it, preventing it from being called more than once
            properties.didReceiveRemoteNotificationFetchCompletionHandler = nil
            
            print("Calling completionhandler didReceiveRemoteNotificationFetch...")
            completionHandler(result)
        }
    }
    @objc func runDidReceiveRemoteNotificationFetchCompletionHandlerIfFailed(_ timer: Timer?) {
        // If we're gonna call the completion handler, then we're at a point in time AT the timer expired, so we
        // don't need that timer anymore.
        if properties.didReceiveRemoteNotificationFetchCompletionHandlerTimer != nil {
            print("failed to call remote notif completion handler before 10 seconds")
            properties.didReceiveRemoteNotificationFetchCompletionHandlerTimer?.invalidate()
            properties.didReceiveRemoteNotificationFetchCompletionHandlerTimer = nil
        }
        
        if let completionHandler: ((UIBackgroundFetchResult) -> Void) = properties.didReceiveRemoteNotificationFetchCompletionHandler {
            print("calling completionhandler didReceiveRemoteNotificationFetch based on timer")
            completionHandler(UIBackgroundFetchResult.failed)
        }
    }
    
    
    // MARK: local notification handling
    //Here you decide whether to silently handle the notification or still alert the user.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        delegate?.handleLocalNotification(notification)
        if delegate == nil {
            print("3 Did you forget to set the delegate of the NotificationManager (see example implementation on top of file)?")
        }
        
        //Write you app specific code here
        completionHandler([.alert, .sound]) //execute the provided completion handler block with the delivery option (if any) that you want the system to use. If you do not specify any options, the system silences the notification.
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // TODO implement
        completionHandler()
    }
    
    
    // MARK: remote notification handling
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("\(application.applicationState)")
        
        // Save the completionhandler. This way we have enough time to start live tracking and then
        // call the completionhandler when we're pretty sure everything is up and running
        // or not gonna run at all (10 seconds?)
        
        properties.didReceiveRemoteNotificationFetchCompletionHandler = completionHandler
        delegate?.handleRemoteNotificationWithUserInfo(userInfo, whenDone: { (result: UIBackgroundFetchResult) in
            self.runDidReceiveRemoteNotificationFetchCompletionHandler(result)
        })
        if delegate == nil {
            print("4 Did you forget to set the delegate of the NotificationManager (see example implementation on top of file)?")
        }
        // Example of delegate implementation:
        // TODO
        
        /*
         If it's not being called, it could be because of this (documentation):
         As soon as you finish processing the notification, you must call the block in the handler parameter or your app will be terminated. Your app has up to 30 seconds of wall-clock time to process the notification and call the specified completion handler block. In practice, you should call the handler block as soon as you are done processing the notification. The system tracks the elapsed time, power usage, and data costs for your app’s background downloads. Apps that use significant amounts of power when processing push notifications may not always be woken up early to process future notifications.
         Also see: http://stackoverflow.com/questions/26959472/silent-push-notifications-only-delivered-if-device-is-charging-and-or-app-is-for
         */
        

    }
    
    
    
    // Status methods
    
    /**
     - note: if `allowed` is `nil`, it means the authorizationstatus is undetermined
     */
    static func userNotificationsAllowed(callBack: @escaping ((_ allowed: Bool?) -> Void) ) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { (unSettings: UNNotificationSettings) in
            if unSettings.authorizationStatus == .notDetermined {
                callBack(nil) // not determined
            }
            
            callBack(unSettings.authorizationStatus == .authorized && unSettings.alertSetting == .enabled && unSettings.badgeSetting == .enabled)
        })
    }
    
//    private func readTokenString(fromDeviceToken deviceToken: Data?) -> String? {
//        guard deviceToken != nil else {
//            return nil
//        }
//
//        return String(data: deviceToken!.base64EncodedData(), encoding: .utf8)?.trimmingCharacters(in: CharacterSet.whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
//    }
}
