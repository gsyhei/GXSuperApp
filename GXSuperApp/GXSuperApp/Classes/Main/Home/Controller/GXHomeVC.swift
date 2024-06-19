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
    @IBOutlet weak var selectTagsView: GXSelectTagsView!
    @IBOutlet weak var ongoingView: UIView!
    @IBOutlet weak var ongoingButton: UIButton!
    
    private weak var locationMarker: GMSMarker?
    private weak var selectedMarker: GXCustomMarker?
    private weak var selectedMarkerMenu: GXSelectedMarkerInfoView?
    private let zoomLarge: Float = 15.0
    private var lastTarget: CLLocationCoordinate2D?
    private var lastIsZoomLarge: Bool = false
    private var markerList: [GXCustomMarker] = []

    private lazy var panView: GXHomePanView = {
        return GXHomePanView(frame: self.view.bounds).then {
            $0.backgroundColor = .clear
        }
    }()
    
    private lazy var mapView: GMSMapView = {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition(latitude: -33.868, longitude: 151.2086, zoom: 12)
        return GMSMapView(options: options).then {
            $0.preferredFrameRate = .maximum
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
        let panCenterY = top + height/2 - 44.0
        let panBottomY = top + height - 176.0
        self.mapView.frame = CGRect(x: 0, y: top, width: width, height: height)
        self.panView.frame = CGRect(x: 0, y: top, width: width, height: height)
        self.panView.setupPanMovedY(top: panTopY, center: panCenterY, bottom: panBottomY)
    }

    override func loadView() {
        super.loadView()
        
        self.myLocationButton.setLayerShadow(color: .lightGray, offset: .zero, radius: 3.0)
        self.myLocationButton.layer.shadowOpacity = 0.5
        
        self.ongoingView.setLayerShadow(color: .gx_green, offset: .zero, radius: 8.0)
        self.ongoingView.layer.shadowOpacity = 0.5
        self.ongoingButton.setBackgroundColor(.gx_green, for: .normal)
        
        let frame = CGRect(x: 12, y: 10, width: 16, height: 16)
        let circleHUDView = MBProgressHUD.CircleHUDView(frame: frame, lineWidth: 2.0)
        self.ongoingView.addSubview(circleHUDView)
        
        self.view.insertSubview(self.panView, aboveSubview: self.myLocationButton)
        self.view.insertSubview(self.mapView, belowSubview: self.myLocationButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        self.panView.changePositionAction = {[weak self] position in
            guard let `self` = self else { return }
            switch position {
            case .top:
                self.myLocationButton.isHidden = true
                self.mapView.isUserInteractionEnabled = false
            case .center:
                self.myLocationButton.isHidden = false
                self.mapView.isUserInteractionEnabled = true
                let bottom = self.mapView.bottom - self.panView.panCenterY - 22.0
                UIView.animate(.promise, duration: 0.2) {
                    self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
                }
            case .bottom:
                self.myLocationButton.isHidden = false
                self.mapView.isUserInteractionEnabled = true
                let bottom = self.mapView.bottom - self.panView.panBottomY - 22.0
                UIView.animate(.promise, duration: 0.2) {
                    self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
                }
            default:
                self.myLocationButton.isHidden = false
                self.mapView.isUserInteractionEnabled = true
                let bottom = self.mapView.bottom - (SCREEN_HEIGHT - GXSelectedMarkerInfoView.menuHeight())
                UIView.animate(.promise, duration: 0.2) {
                    self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
                }
            }
        }
        
        GXLocationManager.shared.requestGeocodeCompletion {[weak self] (isAuth, cityName, location) in
            guard let `self` = self else { return }
            guard isAuth else {
                self.showAlertNotLocation(); return
            }
            guard let letLocation = location else { return }
            if let existingMaker = self.locationMarker {
                UIView.animate(.promise, duration: 0.2) {
                    existingMaker.position = letLocation.coordinate
                    existingMaker.rotation = letLocation.course
                }
            } else {
                let marker = GMSMarker(position: letLocation.coordinate)
                marker.icon = UIImage(named: "home_map_ic_direction")
                marker.rotation = letLocation.course
                marker.map = self.mapView
                self.locationMarker = marker
                self.mapView.animate(with: GMSCameraUpdate.setTarget(letLocation.coordinate, zoom: self.zoomLarge))
                self.lastIsZoomLarge = true
                self.mapView.delegate = self
                
                self.mapViewSetMarkers()
            }
        }
    }
    
}

private extension GXHomeVC {
    
    func showAlertNotLocation() {
        let title = "Location permission"
        let message = "Can better recommend the station around you"
        GXUtil.showAlert(title: title, message: message, cancelTitle: "Disagree", actionTitle: "Agree") { alert, index in
            guard index == 1 else { return }
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, completionHandler: nil)
            }
        }
    }
    
    func mapViewClearMarkers() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.mapViewClearMarkers()
            }
        }
        self.markerList.forEach { marker in
            marker.map = nil
        }
        self.markerList.removeAll()
    }
    
    func mapViewSetMarkers() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.mapViewSetMarkers()
            }
        }
        let target = self.locationMarker?.position ?? self.mapView.camera.target
        
        let coordinate1 = CLLocationCoordinate2D(latitude: target.latitude + 0.0008, longitude: target.longitude + 0.0008)
        let marker = GXCustomMarker(position: coordinate1)
        marker.setMarkerStatus(isSelected: false, isZoomLarge: self.lastIsZoomLarge)
        marker.map = self.mapView
        self.markerList.append(marker)
        
        let coordinate2 = CLLocationCoordinate2D(latitude: target.latitude - 0.0008, longitude: target.longitude - 0.0008)
        let marker1 = GXCustomMarker(position: coordinate2)
        marker1.setMarkerStatus(isSelected: false, isZoomLarge: self.lastIsZoomLarge)
        marker1.map = self.mapView
        self.markerList.append(marker1)
    }
    
    func mapViewUpdateMarkers(isZoomLarge: Bool) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.mapViewUpdateMarkers(isZoomLarge: isZoomLarge)
            }
        }
        guard self.lastIsZoomLarge != isZoomLarge else { return }
        self.lastIsZoomLarge = isZoomLarge
        
        self.markerList.forEach { marker in
            let isSelected = marker == self.selectedMarker
            marker.setMarkerStatus(isSelected: isSelected, isZoomLarge: isZoomLarge)
        }
    }
    
    func mapViewDidTapMarker(marker: GXCustomMarker) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.mapViewDidTapMarker(marker: marker)
            }
        }
        guard marker != self.selectedMarker else { return }

        self.selectedMarker?.setMarkerStatus(isSelected: false, isZoomLarge: self.lastIsZoomLarge)
        marker.setMarkerStatus(isSelected: true, isZoomLarge: self.lastIsZoomLarge)
        self.selectedMarker = marker
        
        // 菜单设置
        if self.selectedMarkerMenu == nil {
            self.panView.setCurrentPanPosition(position: .none, animated: true)
            let menu = GXSelectedMarkerInfoView.showSelectedMarkerInfoView(to: self)
            menu.closeAction = {[weak self] in
                guard let `self` = self else { return }
                self.panView.setCurrentPanPosition(position: self.panView.lastPanPosition, animated: true)
                self.selectedMarker?.setMarkerStatus(isSelected: false, isZoomLarge: self.lastIsZoomLarge)
                self.selectedMarker = nil
                self.selectedMarkerMenu = nil
            }
            self.selectedMarkerMenu = menu
        }
        else {
            // 更新当前self.selectedMarkerMenu
        }
        
    }
    
}

private extension GXHomeVC {
    
    @IBAction func searchButtonClicked(_ sender: Any?) {
        let vc = GXHomeSearchVC.xibViewController()
        let navc = GXBaseNavigationController(rootViewController: vc)
        self.searchButton.hero.id = vc.homeSearchVCHeroId
        navc.hero.isEnabled = true
        navc.modalPresentationStyle = .fullScreen
        self.present(navc, animated: true)
    }
    
    @IBAction func filterButtonClicked(_ sender: Any?) {
        
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
        guard let tapMarker = marker as? GXCustomMarker else { return false }
        self.mapViewDidTapMarker(marker: tapMarker)
        
        return true
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        XCGLogger.info("mapView position.zoom = \(position.zoom)")
        XCGLogger.info("mapView position.target = \(position.target)")
        
        let isZoomLarge = position.zoom >= self.zoomLarge
        if let lastTarget = self.lastTarget {
            let distance = GXLocationManager.getDistanceTo(coordinate1: lastTarget, coordinate2: position.target)
            if distance > 50000 {
                self.lastTarget = position.target
                self.lastIsZoomLarge = isZoomLarge
                // 重新拉取地图场站
            }
            else {
                // 更新场站Markers大小
                self.mapViewUpdateMarkers(isZoomLarge: isZoomLarge)
            }
        } else {
            self.lastTarget = position.target
            self.lastIsZoomLarge = isZoomLarge
            // 首次拉取地图场站
        }
    }
    
}
