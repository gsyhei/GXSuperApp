//
//  GXPlacesManager.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/11.
//

import UIKit


struct GXPlace: Codable {
    var placeID: String?
    var address: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees

    init(placeID: String?, address: String?, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.placeID = placeID
        self.address = address ?? ""
        self.latitude = latitude
        self.longitude = longitude
    }
    init(placeID: String?, address: String?, coordinate: CLLocationCoordinate2D) {
        self.placeID = placeID
        self.address = address ?? ""
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

class GXPlacesManager: NSObject {
    private let placeKey: String = "GXPlaceKey"
    private let maxSaveCount = 50
    static let shared: GXPlacesManager = GXPlacesManager()
    
    lazy var places: [GXPlace] = {
        return self.decodedPlaces()
    }()
    
    func addPlaces(place: GXPlace) {
        if self.places.contains(where: { $0.placeID == place.placeID }) { return }
        
        if self.places.count < self.maxSaveCount {
            self.places.insert(place, at: 0)
            self.encodedPlaces(places: self.places)
        }
        else {
            self.places.removeLast()
            self.places.insert(place, at: 0)
            self.encodedPlaces(places: self.places)
        }
    }
    
    func clearPlaces() {
        self.places.removeAll()
        UserDefaults.standard.removeObject(forKey: self.placeKey)
        UserDefaults.standard.synchronize()
    }
    
    func encodedPlaces(places: [GXPlace]) {
        if let encodedPlaces = try? JSONEncoder().encode(places) {
            UserDefaults.standard.set(encodedPlaces, forKey: self.placeKey)
            UserDefaults.standard.synchronize()
        }
    }
    func decodedPlaces() -> [GXPlace] {
        guard let data = UserDefaults.standard.data(forKey: self.placeKey) else { return [] }
        guard let decodedPlaces = try? JSONDecoder().decode([GXPlace].self, from: data) else { return [] }
        return decodedPlaces
    }
    
}


