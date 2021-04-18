//
//  LocationPostingManager.swift
//  GeofenceMonitor
//
//  Created by David Lindsay on 4/16/21.
//

import Foundation
import CoreLocation

enum GeofenceEvent: String {
  case enter = "enter"
  case exit = "exit"
}

public class LocationPostingManager: NSObject, CLLocationManagerDelegate {
    var region: CLCircularRegion?
    let radius: Double = 80.0   // meters
    let identifier = "region1"  // geofence identifier
    let distanceFilter: Double = 25.0     // meters

    lazy var locationManager = CLLocationManager()
    var userID = ""
    
    public init(userID: String) {
        super.init()
        self.userID = userID
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = self.distanceFilter
    }
    
    func startMonitoring() {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            return
        }
        if let region = region {
            locationManager.startMonitoring(for: region)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
      if region is CLCircularRegion {
        handleEvent(for: region, action: GeofenceEvent.enter.rawValue)
      }
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
      if region is CLCircularRegion {
        handleEvent(for: region, action: GeofenceEvent.enter.rawValue)
      }
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways , .authorizedWhenInUse:
            if region == nil {
                // Set the center of the region to the user's current location when the region has not been initialized.
                let currentLocation = locationManager.location
                if let currentLocation = currentLocation {
                    let centerCoodinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
                    region = CLCircularRegion(center: centerCoodinate, radius: radius, identifier: identifier)
                }
            }
            startMonitoring()
        case .notDetermined , .denied , .restricted:
            break
        default:
            break
        }
        
        switch manager.accuracyAuthorization {
        case .fullAccuracy:
            break
        case .reducedAccuracy:
            break
        default:
            break
        }
    }
    
    func handleEvent(for region: CLRegion, action: String) {
        let region1 = region as? CLCircularRegion
        if let region1 = region1 {
            let center = region1.center
            let latitude = center.latitude
            let longitude = center.longitude
            CoreDataManager.shared.postLocation(userID: userID, geofenceLatitude: latitude, geofenceLongitude: longitude, action: action)
        }
    }
}
