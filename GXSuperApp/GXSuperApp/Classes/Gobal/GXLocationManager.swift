//
//  GXLocationManager.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/6/2.
//

import UIKit
import CoreLocation
import XCGLogger

class GXLocationManager: NSObject {
    private var locationManager: CLLocationManager?
    private var completionHandler: ((Bool, String?, CLLocation?) -> Void)?
    public var cityName: String?
    public var currentLocation: CLLocation?

    static let shared: GXLocationManager = {
        let instance = GXLocationManager()
        return instance
    }()
        
    override init() {
        super.init()
        self.configLocationManager()
    }
    
    private func configLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.distanceFilter = 5.0
    }
    
    func requestGeocodeCompletion(_ hander: @escaping ((Bool, String?, CLLocation?) -> Void)) {
        self.completionHandler = hander

        if self.locationManager?.authorizationStatus == .notDetermined {
            self.locationManager?.requestWhenInUseAuthorization()
        }
        else if self.locationManager?.authorizationStatus == .authorizedAlways {
            self.locationManager?.startUpdatingLocation()
        }
        else if self.locationManager?.authorizationStatus == .authorizedWhenInUse {
            self.locationManager?.startUpdatingLocation()
        }
    }

    func getUserDistanceTo(latitude: Double, longitude: Double) -> String? {
        guard let userLocation = self.currentLocation else { return nil }

        let toLocation = CLLocation(latitude: latitude, longitude: longitude)
        let toDistance = userLocation.distance(from: toLocation)
        let toDistanceStr = String(format: "%.1fkm", toDistance/1000.0)
        
        return toDistanceStr
    }
    
    class func getDistanceTo(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)
        let location2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
        let toDistance = location1.distance(from: location2)
        
        return toDistance
    }
}

extension GXLocationManager: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined {
            self.locationManager?.requestWhenInUseAuthorization()
        }
        else if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.locationManager?.startUpdatingLocation()
        }
        else {
            DispatchQueue.main.async {
                self.completionHandler?(false, nil, nil)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //self.locationManager?.stopUpdatingLocation()
        if let location = locations.first {
            self.reverseGeocoder(currentLocation: location)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager?.stopUpdatingLocation()
        DispatchQueue.main.async {
            self.completionHandler?(true, nil, nil)
        }
    }
    
    private func reverseGeocoder(currentLocation: CLLocation) {
        self.currentLocation = currentLocation
        CLGeocoder().reverseGeocodeLocation(currentLocation) { placemarks, error in
            if error != nil || (placemarks?.count ?? 0) == 0 {
                DispatchQueue.main.async {
                    self.completionHandler?(true, nil, currentLocation)
                }
            }
            else if let placemark: CLPlacemark = placemarks?.first {
                let cityName = (placemark.locality != nil) ? placemark.locality:placemark.administrativeArea
                self.cityName = cityName
                DispatchQueue.main.async {
                    self.completionHandler?(true, cityName, currentLocation)
                }
            }
        }
    }
    
}
