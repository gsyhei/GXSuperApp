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
    
    private lazy var iconOriginalView: GXMarkerIconView = {
        return GXMarkerIconView.createIconView()
    }()
    
    func setMarkerStatus(isSelected: Bool, isZoomLarge: Bool) {
        guard self.isSelected != isSelected || self.isZoomLarge != isZoomLarge else {
            return
        }
        self.isSelected = isSelected
        self.isZoomLarge = isZoomLarge
        
        if isSelected {
            iconOriginalView.updateStatus(isSelected: true)
            self.icon = iconOriginalView.snapshotImage()
        }
        else {
            if isZoomLarge {
                iconOriginalView.updateStatus(isSelected: false)
                self.icon = iconOriginalView.snapshotImage()
            }
            else {
                self.icon = UIImage(named: "home_map_ic_station")
            }
        }
    }
    
}
