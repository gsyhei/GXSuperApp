//
//  GXNavigationManager.swift
//  GXSuperApp
//
//  Created by Gin on 2024/9/1.
//

import UIKit
import MapKit

struct GXNavigationModel {
    var title: String
    var url: String?
    
    init(title: String, url: String? = nil) {
        self.title = title
        self.url = url
    }
}

class GXNavigationManager: NSObject {
    
    class func getInstalledMapEndLocation(coordinate: CLLocationCoordinate2D, endAddress: String) -> [GXNavigationModel] {
        var list: [GXNavigationModel] = []
        
        //苹果地图
        list.append(GXNavigationModel(title: "Apple Maps"))
        
        //谷歌地图
        if let url = URL(string: "qqmap://"), UIApplication.shared.canOpenURL(url) {
            let urlStr = String(format: "comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",
                                APP_NAME, "comgooglemapsnavi", coordinate.latitude, coordinate.longitude, endAddress)
            let encodedUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            list.append(GXNavigationModel(title: "Google Maps", url: encodedUrlStr))
        }
        
//        //百度地图
//        if let url = URL(string: "baidumap://"), UIApplication.shared.canOpenURL(url) {
//            let urlStr = String(format: "baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=%@&mode=driving&coord_type=gcj02",
//                                coordinate.latitude, coordinate.longitude, endAddress)
//            let encodedUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//            list.append(GXNavigationModel(title: "百度地图", url: encodedUrlStr))
//        }
//        
//        //高德地图
//        if let url = URL(string: "iosamap://"), UIApplication.shared.canOpenURL(url) {
//            let urlStr = String(format: "iosamap://path?sourceApplication=%@&backScheme=%@&dlat=%f&dlon=%f&dname=%@&dev=0&style=2",
//                                APP_NAME, "iosamapnavi", coordinate.latitude, coordinate.longitude, endAddress)
//            let encodedUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//            list.append(GXNavigationModel(title: "高德地图", url: encodedUrlStr))
//        }
//        
//        //腾讯地图
//        if let url = URL(string: "qqmap://"), UIApplication.shared.canOpenURL(url) {
//            let urlStr = String(format: "qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%f,%f&to=%@&coord_type=1&policy=0",
//                                coordinate.latitude, coordinate.longitude, endAddress)
//            let encodedUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//            list.append(GXNavigationModel(title: "腾讯地图", url: encodedUrlStr))
//        }
        
        return list
    }
    
    class func showNavigation(coordinate: CLLocationCoordinate2D, endAddress: String) {
        let list = GXNavigationManager.getInstalledMapEndLocation(coordinate: coordinate, endAddress: endAddress)
        
        var actions: [GXAlertAction] = []
        for item in list {
            let action = GXAlertAction()
            action.title = item.title
            action.titleColor = .gx_drakGreen
            action.titleFont = .gx_boldFont(size: 17)
            action.height = 50.0
            if let urlStr = item.url, let url = URL(string: urlStr) {
                action.action = { alertView in
                    alertView.hide(animated: true)
                    UIApplication.shared.open(url)
                }
            }
            else {
                action.action = { alertView in
                    alertView.hide(animated: true)
                    GXNavigationManager.navAppleMap(coordinate: coordinate, endAddress: endAddress)
                }
            }
            actions.append(action)
        }
        GXUtil.showSheet(title: "Navigate", cancelTitle: "Cancel", otherActions: actions)
    }
    
    /// 苹果地图
    class func navAppleMap(coordinate: CLLocationCoordinate2D, endAddress: String) {
        let curLocation = MKMapItem.forCurrentLocation()
        let toLocation = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
        toLocation.name = endAddress
        
        let dict: [String: Any] = [
            MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
            MKLaunchOptionsMapTypeKey : MKMapType.standard,
            MKLaunchOptionsShowsTrafficKey : true
        ]
        MKMapItem.openMaps(with: [curLocation, toLocation], launchOptions: dict)
    }
    
}
