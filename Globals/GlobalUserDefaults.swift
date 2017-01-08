//
//  UserDefaults.swift
//  
//
//  Created by Arjan on 04/04/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit


struct GlobalUserDefaults {
    private static let defaults = UserDefaults.standard
    
    static let NotificationDeviceTokenSetNotificationName = "NotificationDeviceTokenSetNotificationName"
    private static let NotificationDeviceTokenKey = "NotificationDeviceTokenKey"
    /**
     This is the push notification token that Apple gives when we registered our application for it,
     and we got the user's consent. When a valid token is set, a notification will be posted with the 
     name `NotificationDeviceTokenSetNotificationName` and the object `nil`.
     */
    static var NotificationDeviceToken: String? {
        get {
//            if defaults.stringForKey(NotificationDeviceTokenKey) == nil {
//                defaults.setObject("", forKey: NotificationDeviceTokenKey)
//            }
            return defaults.string(forKey: NotificationDeviceTokenKey)
        }
        set(token) {
            defaults.set(token, forKey: NotificationDeviceTokenKey)
            if token != nil && token != "" {
                print("\n new push token: \(token!) \n")
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationDeviceTokenSetNotificationName), object: nil)
            }
        }
    }
}
//
//
//
//+(NSString *)applicationToken {
//    if (![[NSUserDefaults standardUserDefaults] stringForKey:APPLICATION_TOKEN_SETTINGS_KEY]) {
//        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:APPLICATION_TOKEN_SETTINGS_KEY];
//    }
//    return [[NSUserDefaults standardUserDefaults] stringForKey:APPLICATION_TOKEN_SETTINGS_KEY];
//}
//+(void)setApplicationToken:(NSString *)token {
//    [[NSUserDefaults standardUserDefaults] setObject:token forKey:APPLICATION_TOKEN_SETTINGS_KEY];
//    [self setSessionToken:@""];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    if ([token isEqualToString:@""]) {
//        DLog(@"Setting application token & session token to nil");
//        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[LoginManager sharedManager] showLoginViewOnSuccess:nil];
//                });
//        }
//    }
//}
//
//
//+(NSString *)notificationDeviceToken {
//    if (![[NSUserDefaults standardUserDefaults] stringForKey:REMOTE_NOTIFICATIONS_TOKEN_SETTINGS_KEY]) {
//        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:REMOTE_NOTIFICATIONS_TOKEN_SETTINGS_KEY];
//    }
//    return [[NSUserDefaults standardUserDefaults] stringForKey:REMOTE_NOTIFICATIONS_TOKEN_SETTINGS_KEY];
//}
//+(void)setNotificationDeviceToken:(NSString *)token {
//    [[NSUserDefaults standardUserDefaults] setObject:token forKey:REMOTE_NOTIFICATIONS_TOKEN_SETTINGS_KEY];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDeviceTokenChanged object:nil];
//}
//
//#pragma mark - Route settings
//
//+(BOOL)startedWork {
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_KEY_STARTED_WORK]) {
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SETTINGS_KEY_STARTED_WORK];
//    }
//    return [[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_KEY_STARTED_WORK];
//}
//+(void)setStartedWork:(BOOL)startedWork {
//    [[NSUserDefaults standardUserDefaults] setBool:startedWork forKey:SETTINGS_KEY_STARTED_WORK];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//+(NSInteger)currentRouteId {
//    if (![[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_KEY_CURRENT_ROUTE_ID]) {
//        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:SETTINGS_KEY_CURRENT_ROUTE_ID];
//    }
//    return [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_KEY_CURRENT_ROUTE_ID];
//}
//
//+(void)setCurrentRouteId:(NSInteger)currentRouteId {
//    [[NSUserDefaults standardUserDefaults] setInteger:currentRouteId forKey:SETTINGS_KEY_CURRENT_ROUTE_ID];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
