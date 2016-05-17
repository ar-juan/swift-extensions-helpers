//
//  LocationHelper.swift
//  Jeeves
//
//  Created by Arjan on 15/04/16.
//

import Foundation
import MapKit

struct LocationHelper {
    static func estimatedTravelTimeFromMapItem(from: MKMapItem, toMapItem to: MKMapItem, arrival: NSDate, transportType: MKDirectionsTransportType, completion: ((resultString: String) -> Void)) {
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.transportType = transportType
        directionsRequest.arrivalDate = arrival
        directionsRequest.source = from // MKMapItem(placemark: from)
        directionsRequest.destination = to //MKMapItem(placemark: to)
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculateETAWithCompletionHandler({ (response: MKETAResponse?, error: NSError?) in
            if error != nil {
                logthis("directions error: \(error?.localizedDescription) (\(error?.localizedFailureReason))")
                completion(resultString: "Onbekend")
            } else {
                
                if let expectedTravelTime = response?.expectedTravelTime {
                    let ETAComponents = NSCalendar.currentCalendar().components([.Day, .Hour, .Minute, /*.Second*/], fromDate: NSDate(), toDate: NSDate(timeInterval: expectedTravelTime, sinceDate: NSDate()), options: [])
                    let days = ETAComponents.day
                    let hours = ETAComponents.hour
                    let minutes = ETAComponents.minute
                    //let sec = ETAComponents.second
                    
                    var result = ""
                    if days > 0 { result += "\(days) dag(en) " }
                    if hours > 0 { result += "\(hours) uur " }
                    if minutes > 0 { result += "\(minutes) min " }
                    //if sec > 0 { result += "\(sec) sec " }
                    
                    completion(resultString: result)
                }
            }
            
        })
    }
}