//
//  LocationHelper.swift
//  
//
//  Created by Arjan on 15/04/16.
//

import Foundation
import MapKit

struct LocationHelper {
    static func estimatedTravelTimeFromMapItem(_ from: MKMapItem, toMapItem to: MKMapItem, arrival: Date, transportType: MKDirectionsTransportType, completion: @escaping ((_ resultString: String) -> Void)) {
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.transportType = transportType
        directionsRequest.arrivalDate = arrival
        directionsRequest.source = from // MKMapItem(placemark: from)
        directionsRequest.destination = to //MKMapItem(placemark: to)
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculateETA { (response: MKETAResponse?, error: Error?) in
            if error != nil {
                logthis("directions error: \(String(describing: error?.localizedDescription))")
                completion("Onbekend")
            } else {
                
                if let expectedTravelTime = response?.expectedTravelTime {
                    let ETAComponents = (Calendar.current as NSCalendar).components([.day, .hour, .minute, /*.Second*/], from: Date(), to: Date(timeInterval: expectedTravelTime, since: Date()), options: [])
                    let days = ETAComponents.day
                    let hours = ETAComponents.hour
                    let minutes = ETAComponents.minute
                    //let sec = ETAComponents.second
                    
                    var result = ""
                    if days! > 0 { result += "\(days!) dag(en) " }
                    if hours! > 0 { result += "\(hours!) uur " }
                    if minutes! > 0 { result += "\(minutes!) min " }
                    //if sec > 0 { result += "\(sec) sec " }
                    
                    completion(result)
                }
            }
        }
    }
}
