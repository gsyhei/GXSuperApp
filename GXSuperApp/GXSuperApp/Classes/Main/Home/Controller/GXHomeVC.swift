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
        return GXHomePanView(frame: self.view.bounds, viewModel: self.viewModel).then {
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
    
    private lazy var viewModel: GXHomeViewModel = {
        return GXHomeViewModel()
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
        
        self.ongoingView.isHidden = true
//        进行中的订单
//        self.ongoingView.setLayerShadow(color: .gx_green, offset: .zero, radius: 8.0)
//        self.ongoingView.layer.shadowOpacity = 0.5
//        self.ongoingButton.setBackgroundColor(.gx_green, for: .normal)
//        self.ongoingButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
//        let frame = CGRect(x: 12, y: 10, width: 16, height: 16)
//        let circleHUDView = MBProgressHUD.CircleHUDView(frame: frame, lineWidth: 2.0)
//        self.ongoingView.addSubview(circleHUDView)
        
        self.view.insertSubview(self.panView, aboveSubview: self.myLocationButton)
        self.view.insertSubview(self.mapView, belowSubview: self.myLocationButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestDictListAvailable()
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
        self.panView.didSelectRowAtAction = {[weak self] model in
            guard let `self` = self else { return }
            
            let vc = GXHomeDetailVC.xibViewController().then {
                $0.viewModel.rowModel = model
                $0.hidesBottomBarWhenPushed = true
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        self.selectTagsView.itemAction = {[weak self] in
            guard let `self` = self else { return }
            guard let _ = self.locationMarker else { return }
            /// 判断已获取到位置
            self.requestStationConsumerQuery()
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
            }
        }
    }
    
}

private extension GXHomeVC {
    
    func requestStationConsumerQuery() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestStationConsumerQuery()
        }.done { model in
            MBProgressHUD.dismiss()
            self.mapViewSetMarkers()
            self.panView.tableViewReloadData()
        }.catch { error in
            MBProgressHUD.dismiss()
            MBProgressHUD.showError(text:error.localizedDescription)
        }
    }
    
    func requestDictListAvailable() {
        MBProgressHUD.showLoading()
        let combinedPromise = when(fulfilled: [
            self.viewModel.requestParamConsumer(),
            self.viewModel.requestDictListAvailable()
        ])
        firstly {
            combinedPromise
        }.done { models in
            self.selectTagsView.dataSource.data = GXUserManager.shared.dictListAvailable
            MBProgressHUD.dismiss()
        }.catch { error in
            MBProgressHUD.dismiss()
            MBProgressHUD.showError(text:error.localizedDescription)
        }
    }
    
    func showAlertNotLocation() {
        let title = "Location permission"
        let message = "Can better recommend the station around you"
        GXUtil.showAlert(title: title, message: message, cancelTitle: "Disagree", actionTitle: "Agree", actionHandler: { alert, index in
            guard index == 1 else { return }
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, completionHandler: nil)
            }
        })
    }
    
    func mapViewClearMarkers() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.mapViewClearMarkers()
            }
        }
        self.markerList.forEach { marker in
            if marker != self.selectedMarker {
                marker.map = nil
            }
        }
        if let marker = self.selectedMarker {
            self.markerList = [marker]
        }
    }
    
    func mapViewSetMarkers() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.mapViewSetMarkers()
            }
        }
        self.mapViewClearMarkers()
        for item in self.viewModel.stationConsumerList {
            guard item.id != self.selectedMarker?.model?.id else { continue }
            let coordinate = CLLocationCoordinate2D(latitude: item.lat, longitude: item.lng)
            let marker = GXCustomMarker(position: coordinate, model: item)
            marker.updateMarker(isSelected: false, isZoomLarge: self.lastIsZoomLarge, isCreate: true)
            marker.map = self.mapView
            self.markerList.append(marker)
        }
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
            let isSelected = (marker == self.selectedMarker)
            marker.updateMarker(isSelected: isSelected, isZoomLarge: isZoomLarge)
        }
    }
    
    func mapViewDidTapMarker(marker: GXCustomMarker) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.mapViewDidTapMarker(marker: marker)
            }
        }
        guard marker != self.selectedMarker else { return }

        self.selectedMarker?.updateMarker(isSelected: false, isZoomLarge: self.lastIsZoomLarge)
        marker.updateMarker(isSelected: true, isZoomLarge: self.lastIsZoomLarge)
        self.selectedMarker = marker
        
        if self.selectedMarkerMenu == nil {
            self.panView.setCurrentPanPosition(position: .none, animated: true)
            let menu = GXSelectedMarkerInfoView.showSelectedMarkerInfoView(to: self, model: marker.model)
            menu.closeAction = {[weak self] in
                guard let `self` = self else { return }
                self.panView.setCurrentPanPosition(position: self.panView.lastPanPosition, animated: true)
                self.selectedMarker?.updateMarker(isSelected: false, isZoomLarge: self.lastIsZoomLarge)
                self.selectedMarker = nil
                self.selectedMarkerMenu = nil
            }
            self.selectedMarkerMenu = menu
        }
        else {
            self.selectedMarkerMenu?.bindView(model: marker.model)
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
        let height: CGFloat = 580 + UIWindow.gx_safeAreaInsets.bottom
        let menu = GXHomeFilterMenu(height: height)
        menu.confirmAction = {[weak self] in
            self?.selectTagsView.updateSelectedTags()
            self?.requestStationConsumerQuery()
        }
        menu.show(style: .sheetBottom, usingSpring: true)
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
            let maxDistance = (GXUserManager.shared.paramConsumerData?.queryDistance ?? 50) * 1000
            XCGLogger.info("mapView move distance = \(distance), maxDistance = \(maxDistance)")
            if distance > maxDistance {
                self.lastTarget = position.target
                self.lastIsZoomLarge = isZoomLarge
                // 重新拉取地图场站
                GXUserManager.shared.filter.setSelectedCoordinate(position.target)
                self.requestStationConsumerQuery()
            }
            else {
                // 更新场站Markers大小
                self.mapViewUpdateMarkers(isZoomLarge: isZoomLarge)
            }
        } else {
            self.lastTarget = position.target
            self.lastIsZoomLarge = isZoomLarge
            // 首次拉取地图场站
            GXUserManager.shared.filter.setSelectedCoordinate(position.target)
            self.requestStationConsumerQuery()
        }
    }
    
}
