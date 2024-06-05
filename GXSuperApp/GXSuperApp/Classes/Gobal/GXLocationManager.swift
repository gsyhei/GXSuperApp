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

        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager?.requestWhenInUseAuthorization()
        }
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            self.locationManager?.startUpdatingLocation()
        }
        else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.locationManager?.startUpdatingLocation()
        }
        else {
            self.completionHandler?(false, nil, nil)
        }
    }

    func getUserDistanceTo(latitude: Double, longitude: Double) -> String? {
        guard let userLocation = self.currentLocation else { return nil }
        /// 原生计算距离
        let toLocation = CLLocation(latitude: latitude, longitude: longitude)
        let toDistance = userLocation.distance(from: toLocation)
        let toDistanceStr = String(format: "%.1fkm", toDistance/1000.0)
        
        return toDistanceStr
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
            self.completionHandler?(false, nil, nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager?.stopUpdatingLocation()
        if let location = locations.first {
            self.reverseGeocoder(currentLocation: location)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager?.stopUpdatingLocation()
        self.completionHandler?(true, nil, nil)
    }
    
    private func reverseGeocoder(currentLocation: CLLocation) {
        self.currentLocation = currentLocation
        CLGeocoder().reverseGeocodeLocation(currentLocation) { placemarks, error in
            if error != nil || (placemarks?.count ?? 0) == 0 {
                self.completionHandler?(true, nil, currentLocation)
            }
            else if let placemark: CLPlacemark = placemarks?.first {
                var cityName = (placemark.locality != nil) ? placemark.locality:placemark.administrativeArea
                if cityName?.hasSuffix("市") ?? false {
                    cityName = cityName?.replacingOccurrences(of: "市", with: "")
                }
                self.cityName = cityName
                self.completionHandler?(true, cityName, currentLocation)
            }
        }
    }
    
}
