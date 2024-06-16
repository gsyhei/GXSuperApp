//
//  GXCustomMarker.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/13.
//

import UIKit
import GoogleMaps

class GXCustomMarker: GMSMarker {
    
    func setMarkerStatus(isSelected: Bool, isZoomLarge: Bool) {
//        if isSelected {
//            if let iconView = self.iconView as? GXMarkerIconView {
//                iconView.updateStatus(isSelected: true)
//            }
//            else {
//                let iconView = GXMarkerIconView.createIconView()
//                iconView.updateStatus(isSelected: true)
//                self.iconView = iconView
//            }
//        }
//        else {
//            if isZoomLarge {
//                if let iconView = self.iconView as? GXMarkerIconView {
//                    iconView.updateStatus(isSelected: false)
//                }
//                else {
//                    let iconView = GXMarkerIconView.createIconView()
//                    iconView.updateStatus(isSelected: false)
//                    self.iconView = iconView
//                }
//            }
//            else {
//                self.iconView = nil
//            }
//        }
        let iconView = GXMarkerIconView.createIconView()
        iconView.updateStatus(isSelected: false)
        let image = iconView.snapshotImage()
        self.icon = image
        
    }
    
}
