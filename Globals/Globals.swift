//
//  Globals.swift
//  Jeeves
//
//  Created by Arjan on 04/04/16.
//  Copyright © 2016 Auxilium. All rights reserved.
//

import UIKit

struct Globals {
    static let AppFontFamily = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body).familyName
    
    // NSNotification
    static let DatabaseAvailabilityContext: String = "DatabaseAvailabilityContext"
    static let DatabaseAvailabilityNotificationName: String = "Globals.DatabaseAvailabilityNotificationName"
    static let EnteredGeofenceAreaName: String = "EnteredGeofenceAreaName"
    
    
    // MARK: App version and name
    static let AppName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String
    
    private static let BuildNumberStringKey = "BuildNumberStringKey"
    static var BuildNumberString: String {
        get {
            //            if defaults.stringForKey(BuildNumberStringKey) == nil {
            //                defaults.setObject("", forKey: BuildNumberStringKey)
            //            }
            //            return defaults.stringForKey(BuildNumberStringKey)!
            return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        }
        set(buildNumber) {
            //            defaults.setObject(buildNumber, forKey: BuildNumberStringKey)
        }
    }
}

