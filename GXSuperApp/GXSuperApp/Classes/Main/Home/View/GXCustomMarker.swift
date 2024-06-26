//
//  GXCustomMarker.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/13.
//

import UIKit
import GoogleMaps

class GXCustomMarker: GMSMarker {
    var isSelected: Bool = false
    var isZoomLarge: Bool = false
    
    private(set) var model: GXStationConsumerRowsModel?
    private lazy var iconOriginalView: GXMarkerIconView = {
        return GXMarkerIconView.createIconView()
    }()
    
    required convenience init(position: CLLocationCoordinate2D, model: GXStationConsumerRowsModel?) {
        self.init(position: position)
        self.model = model
    }
    
    func updateMarker(isSelected: Bool, isZoomLarge: Bool, isCreate: Bool = false) {
        guard isCreate || (self.isSelected != isSelected || self.isZoomLarge != isZoomLarge) else {
            return
        }
        self.isSelected = isSelected
        self.isZoomLarge = isZoomLarge
        
        if isSelected {
            self.iconOriginalView.bindView(model: model, isSelected: true)
            self.icon = self.iconOriginalView.snapshotImage()
        }
        else {
            if isZoomLarge {
                self.iconOriginalView.bindView(model: model, isSelected: false)
                self.icon = iconOriginalView.snapshotImage()
            }
            else {
                self.icon = UIImage(named: "home_map_ic_station")
            }
        }
    }
    
}
