//
//  GXHomeVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/6.
//

import UIKit
import GoogleMaps
import PromiseKit
import XCGLogger
import MBProgressHUD

class GXHomeVC: GXBaseViewController {
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var ongoingView: UIView!
    @IBOutlet weak var ongoingButton: UIButton!
    
    private let zoomLarge: Float = 15.0
    private var lastTarget: CLLocationCoordinate2D?
    private var lastIsZoomLarge: Bool = false
    private var locationMarker: GMSMarker?
    private var markerList: [GMSMarker] = []
    private var selectedMarker: GMSMarker?

    private var menuHeight: CGFloat {
        return 286.0 + self.view.safeAreaInsets.bottom
    }
    private lazy var panView: GXHomePanView = {
        return GXHomePanView(frame: self.view.bounds).then {
            $0.backgroundColor = .clear
        }
    }()
    
    lazy var mapView: GMSMapView = {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition(latitude: -33.868, longitude: 151.2086, zoom: 12)
        return GMSMapView(options: options).then {
            $0.settings.compassButton = false
            $0.settings.myLocationButton = false
            $0.settings.rotateGestures = false
            $0.isMyLocationEnabled = false
            $0.padding = .zero
        }
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        let top = self.topContainerView.height + self.view.safeAreaInsets.top
        let width = self.view.bounds.width
        let height = self.view.bounds.height - top - self.view.safeAreaInsets.bottom
        let panTopY = top
        let panCenterY = top + height/2 - 30.0
        let panBottomY = top + height - 176.0
        self.mapView.frame = CGRect(x: 0, y: top, width: width, height: height)
        self.panView.frame = CGRect(x: 0, y: top, width: width, height: height)
        self.panView.setupPanMovedY(top: panTopY, center: panCenterY, bottom: panBottomY)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        self.myLocationButton.setLayerShadow(color: .lightGray, offset: .zero, radius: 3.0)
        self.myLocationButton.layer.shadowOpacity = 0.5
        
        self.ongoingView.setLayerShadow(color: .gx_green, offset: .zero, radius: 8.0)
        self.ongoingView.layer.shadowOpacity = 0.5
        self.ongoingButton.setBackgroundColor(.gx_green, for: .normal)
        
        let frame = CGRect(x: 12, y: 10, width: 16, height: 16)
        let circleHUDView = MBProgressHUD.CircleHUDView(frame: frame)
        self.ongoingView.addSubview(circleHUDView)
        
        self.view.insertSubview(self.mapView, belowSubview: self.myLocationButton)
        self.view.insertSubview(self.panView, aboveSubview: self.myLocationButton)
        
        self.panView.changePositionAction = {[weak self] position in
            guard let `self` = self else { return }
            switch position {
            case .top:
                self.myLocationButton.isHidden = true
                self.mapView.isUserInteractionEnabled = false
            case .center:
                self.myLocationButton.isHidden = false
                self.mapView.isUserInteractionEnabled = true
                let bottom = self.mapView.bottom - self.panView.panCenterY
                UIView.animate(.promise, duration: 0.3) {
                    self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
                }
            case .bottom:
                self.myLocationButton.isHidden = false
                self.mapView.isUserInteractionEnabled = true
                let bottom = self.mapView.bottom - self.panView.panBottomY
                UIView.animate(.promise, duration: 0.3) {
                    self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
                }
            default:
                self.myLocationButton.isHidden = false
                self.mapView.isUserInteractionEnabled = true
                let bottom = self.mapView.bottom - (SCREEN_HEIGHT - self.menuHeight)
                UIView.animate(.promise, duration: 0.3) {
                    self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
                }
            }
        }
        
        GXLocationManager.shared.requestGeocodeCompletion {[weak self] (isAuth, cityName, location) in
            guard let `self` = self else { return }
            guard isAuth else {
                // 去设置
                self.mapView.delegate = self
                return
            }
            guard let letLocation = location else {
                self.mapView.delegate = self
                return
            }
            if let existingMaker = self.locationMarker {
                CATransaction.begin()
                CATransaction.setAnimationDuration(2.0)
                existingMaker.position = letLocation.coordinate
                existingMaker.rotation = letLocation.course
                CATransaction.commit()
            } else {
                let marker = GMSMarker(position: letLocation.coordinate)
                marker.icon = UIImage(named: "home_map_ic_direction")
                marker.rotation = letLocation.course
                marker.map = self.mapView
                self.locationMarker = marker
                self.mapView.animate(with: GMSCameraUpdate.setTarget(letLocation.coordinate, zoom: 17))
                self.mapView.delegate = self
                
                self.mapViewSetMarkers()
            }
        }
    }
    
}

private extension GXHomeVC {
    func mapViewClearMarkers() {
        self.markerList.forEach { marker in
            marker.map = nil
        }
        self.markerList.removeAll()
    }
    
    func mapViewSetMarkers() {
        let target = self.locationMarker?.position ?? self.mapView.camera.target
        
        let iconView = GXMarkerIconView.createIconView()
        iconView.updateNumber(title: "222/222")
        let coordinate1 = CLLocationCoordinate2D(latitude: target.latitude + 0.0002, longitude: target.longitude + 0.0002)
        let marker = GMSMarker(position: coordinate1)
        marker.iconView = iconView
        marker.map = self.mapView
        self.selectedMarker = marker
        
        let coordinate2 = CLLocationCoordinate2D(latitude: target.latitude - 0.0002, longitude: target.longitude - 0.0002)
        let marker1 = GMSMarker(position: coordinate2)
        marker1.icon = UIImage(named: "home_map_ic_station")
        marker1.map = self.mapView
    }
    
    func mapViewUpdateMarkers(isZoomLarge: Bool) {
        guard self.lastIsZoomLarge != isZoomLarge else { return }
        self.lastIsZoomLarge = isZoomLarge
        self.mapViewClearMarkers()
    }
    
    func mapViewDidTapMarker(marker: GMSMarker) {
        guard marker != self.selectedMarker else { return }
        
        self.selectedMarker?.iconView = nil
        self.selectedMarker?.icon = UIImage(named: "home_map_ic_station")

        self.selectedMarker = marker
        if let iconView = marker.iconView {
            iconView.backgroundColor = .gx_green
        }
        else {
            let iconView = GXMarkerIconView.createIconView()
            marker.iconView = iconView
        }
    }
    
}

private extension GXHomeVC {
    
    @IBAction func searchButtonClicked(_ sender: Any?) {
        
    }
    
    @IBAction func filterButtonClicked(_ sender: Any?) {
        self.panView.setCurrentPanPosition(position: .none, animated: true)
        
    }
    
    @IBAction func myLocationButtonClicked(_ sender: Any?) {
        guard let coordinate = self.locationMarker?.position, CLLocationCoordinate2DIsValid(coordinate) else {
            return
        }
        self.mapView.layer.cameraLatitude = coordinate.latitude
        self.mapView.layer.cameraLongitude = coordinate.longitude
        self.mapView.layer.cameraBearing = 0
    }
    
    @IBAction func ongoingButtonClicked(_ sender: Any?) {
        
    }
    
}

extension GXHomeVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard marker != self.locationMarker else { return false }
        self.mapViewDidTapMarker(marker: marker)
        
        return true
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        XCGLogger.info("mapView position.zoom = \(position.zoom)")
        XCGLogger.info("mapView position.target = \(mapView.camera.target)")
        
        let isZoomLarge = position.zoom >= self.zoomLarge
        if let lastTarget = self.lastTarget {
            let distance = GXLocationManager.getDistanceTo(coordinate1: lastTarget, coordinate2: position.target)
            if distance > 50000 {
                self.lastTarget = position.target
                self.lastIsZoomLarge = isZoomLarge
                // 重新拉取地图场站
                return
            }
        } else {
            self.lastTarget = position.target
            self.lastIsZoomLarge = isZoomLarge
            // 首次拉取地图场站
            return
        }
        self.mapViewUpdateMarkers(isZoomLarge: isZoomLarge)
    }
    
}
