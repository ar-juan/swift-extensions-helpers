//
//  LocationManager.swift
//
//  Created by Arjan on 04/05/16.
//

import Foundation
import CoreLocation
import MapKit
import CoreData

enum LocationManagerAuthorizationType {
    case None
    case WhenInUse
    case Always
}

protocol LocationManagerControllerDelegate {
    /**
     Should return the `CLAuthorizationStatus` that you want the app to have in terms of requesting location updates
     */
    func minimumLocationAuthorizationStatus() -> CLAuthorizationStatus
    
    /**
     Return nil if no message should be shown
     */
    func messageForPopupIfLocationAuthorizationRequestFailed() -> (message: String, title: String?, goToSetingsActionTitle: String?, dismissActionTitle: String)?
}

/**
 Extend this helper / manager / controller (what is it really?) class to setup your location needs
 - requires: something needs to implement `LocationManagerControllerDelegate` and set itself as `delegate`
 - note: for an example of an extension, see end of this file
 */
class LocationManagerController: NSObject, CLLocationManagerDelegate {
    var delegate: LocationManagerControllerDelegate? {
        didSet {
            if delegate != nil {
                minimumAuthorizationStatus = delegate?.minimumLocationAuthorizationStatus()
            }
        }
    }
    var minimumAuthorizationStatus: CLAuthorizationStatus? = .NotDetermined {
        didSet {
            if minimumAuthorizationStatus != nil && minimumAuthorizationStatus != oldValue {
                if minimumAuthorizationStatus == .AuthorizedWhenInUse {
                    requestAuthorization(requestedStatus: .AuthorizedWhenInUse, forManager: manager)
                    manager.requestWhenInUseAuthorization()
                } else if minimumAuthorizationStatus == .AuthorizedAlways {
                    manager.requestAlwaysAuthorization()
                } else {
                    manager.stopUpdatingLocation()
                    manager.stopMonitoringSignificantLocationChanges()
                    for region in manager.monitoredRegions {
                        manager.stopMonitoringForRegion(region)
                    }
                    minimumAuthorizationStatus = .NotDetermined
                }
                requestAuthorization(requestedStatus: minimumAuthorizationStatus!, forManager: manager)
            }
        }
    }
    
    var manager: CLLocationManager!
    static let sharedInstance = LocationManagerController()
    private override init() {
        super.init()
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.pausesLocationUpdatesAutomatically = true
        manager.activityType = .Other
        //requestAlwaysAuthorizationForManager(manager)
    } // prevents others from using the default '()' initializer for this class.
    
    
    private func requestAuthorization(requestedStatus status: CLAuthorizationStatus, forManager manager: CLLocationManager) {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if status != CLAuthorizationStatus.AuthorizedAlways {
            manager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .NotDetermined ||
            CLLocationManager.authorizationStatus() == .Restricted {
            // do nothing yet
        } else if CLLocationManager.authorizationStatus() != minimumAuthorizationStatus {
            logthis("authorization status failed: \(CLLocationManager.authorizationStatus())")
            
            if let popupMessage = delegate?.messageForPopupIfLocationAuthorizationRequestFailed() {
                let alertController = UIAlertController(title: popupMessage.title, message: popupMessage.message, preferredStyle: .Alert)
                if popupMessage.goToSetingsActionTitle != nil {
                    alertController.addAction(UIAlertAction(title: popupMessage.goToSetingsActionTitle, style: .Default, handler: { (_) in
                        let url: NSURL = NSURL(string: UIApplicationOpenSettingsURLString)!
                        UIApplication.sharedApplication().openURL(url)
                    }))
                }
                alertController.addAction(UIAlertAction(title: popupMessage.dismissActionTitle, style: .Default, handler: nil))
                
                dispatch_async(dispatch_get_main_queue(), {
                    alertController.show()
                })
            }
        } else if minimumAuthorizationStatus == .AuthorizedAlways && UIApplication.sharedApplication().backgroundRefreshStatus != .Available {
            logthis("note: backgroundRefresh not available. Current status: \(CLLocationManager.authorizationStatus())")
        } else if CLLocationManager.locationServicesEnabled() == false {
            logthis("locationServicesEnabled == false")
        } else if minimumAuthorizationStatus == .AuthorizedAlways && !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            logthis("isMonitoringAvailableForClass == false")
        }
    }
    
    
    // CLLocationManagerDelegate
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
        logthis()
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) {
        logthis()
    }
    
    //    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
    //        logthis()
    //    }
    //
    //    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
    //        logthis()
    //    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        //logthis()
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        logthis()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        logthis()
    }
}

/*
 // Example of extension
extension LocationManagerController {
    func startMonitoringGeofenceAreasForAppointments(appointments: [Appointment]) {
        for appointment in appointments {
            guard let geofenceAreas = appointment.poli?.location?.geofenceAreas as? Set<GeofenceArea> else {
                logthis("No geofence areas in appointment with id \(appointment.id?.integerValue)")
                break
            }
            for area in geofenceAreas {
                guard
                    let areaId = area.id?.stringValue,
                    let areaLatitude = area.latitude?.doubleValue,
                    let areaLongitude = area.longitude?.doubleValue,
                    let areaRadius = area.radius?.doubleValue,
                    let uniqueAreaIdentifier = area.uniqueRegionMonitoringIdentifierStringForAppointment(appointment)
                    else {
                        logthis("incomplete data for GeoFenceArea of appointment with id \(appointment.id?.integerValue)")
                        break
                }
                
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: areaLatitude, longitude: areaLongitude), radius: areaRadius, identifier: uniqueAreaIdentifier)
                manager.startMonitoringForRegion(region)
            }
        }
    }
    
    func stopMonitoringGeofenceAreasForAppointments(appointments: [Appointment]) {
        for appointment in appointments {
            guard let geofenceAreas = appointment.poli?.location?.geofenceAreas as? Set<GeofenceArea> else {
                logthis("No geofence areas in appointment with id \(appointment.id?.integerValue)")
                break
            }
            for area in geofenceAreas {
                guard
                    let areaLatitude = area.latitude?.doubleValue,
                    let areaLongitude = area.longitude?.doubleValue,
                    let areaRadius = area.radius?.doubleValue,
                    let uniqueAreaIdentifier = area.uniqueRegionMonitoringIdentifierStringForAppointment(appointment)
                    else {
                        logthis("incomplete data for GeoFenceArea of appointment with id \(appointment.id?.integerValue)")
                        break
                }
                
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: areaLatitude, longitude: areaLongitude), radius: areaRadius, identifier: uniqueAreaIdentifier)
                manager.stopMonitoringForRegion(region)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        logthis()
        
        //let geofenceAreaId = region.identifier
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.useContextWithOperation { (context) in
            context.performBlock({
                if
                    let areaAndAppointment = GeofenceArea.geofenceAreaAndAppointmentFromUniqueRegionMonitoringIdentifierString(region.identifier, usingContext: context) {
                    let area = areaAndAppointment.area
                    let appointment = areaAndAppointment.appointment
                    // show appointment.poli?.availableProducts graphically
                    //
                    //                    let geofenceAreaId = Int(region.identifier),
                    //                    let geofenceArea = GeofenceArea.geofenceAreaWithId(geofenceAreaId, inContext: appDelegate.context),
                    //                    let location = geofenceArea.location
                    
                }
            })
        }
        
        
        
        if let geofenceAreaId = Int(region.identifier) {
            GeofenceArea.geofenceAreaWithId(geofenceAreaId, inContext: appDelegate.context)
        }
        if appDelegate.context == nil {
            appDelegate.prepareDatabaseWhenDone { (success, context) in
                self.locationManager(manager, didEnterRegion: region)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        logthis()
        
        let geofenceAreaId = region.identifier
    }
}
*/