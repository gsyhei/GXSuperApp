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
    @IBOutlet weak var ongoingView: UIView!
    @IBOutlet weak var ongoingButton: UIButton!
    @IBOutlet weak var centerIconTopLC: NSLayoutConstraint!

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
            $0.filterButton.addTarget(self, action: #selector(self.filterButtonClicked), for: .touchUpInside)
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
    
    private lazy var circleHUDView: MBProgressHUD.CircleHUDView = {
        let frame = CGRect(x: 12, y: 10, width: 16, height: 16)
        return MBProgressHUD.CircleHUDView(frame: frame, lineWidth: 2.0)
    }()
    
    private lazy var viewModel: GXHomeViewModel = {
        return GXHomeViewModel()
    }()
    
    deinit {
        XCGLogger.info("GXHomeVC deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppearForAfterLoading() {
        self.requestOrderConsumerDoing()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        let top = self.topContainerView.height + self.view.safeAreaInsets.top
        let width = self.view.bounds.width
        let height = self.view.bounds.height - top - self.view.safeAreaInsets.bottom
        let panTopY = top
        let panCenterY = top + height/2 - 44.0
        let panBottomY = top + height - 212.0
        self.mapView.frame = CGRect(x: 0, y: top, width: width, height: height)
        self.panView.frame = CGRect(x: 0, y: top, width: width, height: height)
        self.panView.setupPanMovedY(top: panTopY, center: panCenterY, bottom: panBottomY)
    }

    override func loadView() {
        super.loadView()
        
        self.myLocationButton.setLayerShadow(color: .lightGray, offset: .zero, radius: 3.0)
        self.myLocationButton.layer.shadowOpacity = 0.5
        
        // 进行中的订单
        self.ongoingView.isHidden = true
        self.ongoingView.setLayerShadow(color: .gx_green, offset: .zero, radius: 8.0)
        self.ongoingView.layer.shadowOpacity = 0.5
        self.ongoingButton.setBackgroundColor(.gx_green, for: .normal)
        self.ongoingButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)

        self.view.insertSubview(self.panView, aboveSubview: self.topContainerView)
        self.view.insertSubview(self.mapView, belowSubview: self.myLocationButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestDictListAvailable()
        
        NotificationCenter.default.rx
            .notification(GX_NotifName_UpdateOrderDoing)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.requestOrderConsumerDoing()
            }).disposed(by: disposeBag)
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
                self.centerIconTopLC.constant = (self.mapView.height - bottom - 24)/2
                UIView.animate(.promise, duration: 0.2) {
                    self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
                    self.view.layoutIfNeeded()
                }
            case .bottom:
                self.myLocationButton.isHidden = false
                self.mapView.isUserInteractionEnabled = true
                let bottom = self.mapView.bottom - self.panView.panBottomY - 22.0
                self.centerIconTopLC.constant = (self.mapView.height - bottom - 24)/2
                UIView.animate(.promise, duration: 0.2) {
                    self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
                    self.view.layoutIfNeeded()
                }
            default:
                self.myLocationButton.isHidden = false
                self.mapView.isUserInteractionEnabled = true
                let bottom = self.mapView.bottom - (SCREEN_HEIGHT - GXSelectedMarkerInfoView.menuHeight())
                self.centerIconTopLC.constant = (self.mapView.height - bottom - 24)/2
                UIView.animate(.promise, duration: 0.2) {
                    self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
                    self.view.layoutIfNeeded()
                }
            }
        }
        self.panView.didSelectRowAtAction = {[weak self] model in
            guard let `self` = self else { return }
            
            let vc = GXHomeDetailVC.createVC(stationId: model.id, distance: model.distance)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.panView.selectTagsView.itemAction = {[weak self] in
            guard let `self` = self else { return }
            guard let _ = self.locationMarker else { return }
            /// 判断已获取到位置
            self.requestStationConsumerQuery()
        }
        self.panView.navigationAction = { model in
            guard let model = model else { return }
            let coordinate = CLLocationCoordinate2D(latitude: model.lat, longitude: model.lng)
            GXNavigationManager.showNavigation(coordinate: coordinate, endAddress: model.address)
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
            if let alerts: [GXAlertView] = UIWindow.gx_frontWindow?.viewsForSuperview() {
                for alert in alerts {
                    if alert.titleLabel.text == "Enable Location" {
                        alert.hide(animated: true)
                    }
                }
            }
        }
    }
    
    override func loginReloadViewData() {
        self.panView.tableViewReloadData()
        self.requestOrderConsumerDoing()
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
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func requestDictListAvailable() {
        MBProgressHUD.showLoading()
        let combinedPromise = when(fulfilled: [
            self.viewModel.requestParamConsumer(),
            self.viewModel.requestDictListAvailable(),
            self.viewModel.requestOrderConsumerDoing(),
            self.viewModel.requestVehicleConsumerList()
        ])
        firstly {
            combinedPromise
        }.done { models in
            MBProgressHUD.dismiss()
            self.panView.selectTagsView.updateDataSource()
            self.updateOrderConsumerDoing()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func requestOrderConsumerDoing() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestOrderConsumerDoing()
        }.done { model in
            MBProgressHUD.dismiss()
            self.updateOrderConsumerDoing()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func updateOrderConsumerDoing() {
        if (GXUserManager.shared.orderDoing != nil) {
            self.ongoingView.addSubview(self.circleHUDView)
            self.ongoingView.isHidden = false
        }
        else {
            self.circleHUDView.removeFromSuperview()
            self.ongoingView.isHidden = true
        }
    }
    
    func showAlertNotLocation() {
        let title = "Enable Location"
        let message = "Allow MarsEnergy to access your location to find nearby stations"
        GXUtil.showAlert(to: UIWindow.gx_frontWindow, title: title, message: message, cancelTitle: "Go to Settings", actionHandler: { alert, index in
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
        vc.searchAction = {[weak self] place in
            guard let `self` = self else { return }
            let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            self.mapView.animate(with: GMSCameraUpdate.setTarget(coordinate, zoom: self.zoomLarge))
        }
        let navc = GXBaseNavigationController(rootViewController: vc)
        self.searchButton.hero.id = vc.homeSearchVCHeroId
        navc.hero.isEnabled = true
        navc.modalPresentationStyle = .fullScreen
        self.present(navc, animated: true)
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
        guard let orderDoing = GXUserManager.shared.orderDoing else { return }
//        /// 费用确认
//        let vc = GXChargingFeeConfirmVC.instantiate()
//        self.navigationController?.pushViewController(vc, animated: true)
//        /// 充电效果
//        let vc = GXChargingCarShowVC.createVC(orderId: orderDoing.id)
//        self.navigationController?.pushViewController(vc, animated: true)
        
        if orderDoing.orderStatus == .CHARGING {
            let vc = GXChargingCarShowVC.createVC(orderId: orderDoing.id)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = GXChargingOrderDetailsVC.createVC(orderId: orderDoing.id)
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    @objc func filterButtonClicked(_ sender: Any?) {
        let height: CGFloat = 580 + UIWindow.gx_safeAreaInsets.bottom
        let menu = GXHomeFilterMenu(height: height)
        menu.confirmAction = {[weak self] in
            self?.panView.selectTagsView.updateSelectedTags()
            self?.requestStationConsumerQuery()
        }
        menu.show(style: .sheetBottom, usingSpring: true)
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
            let maxDistance = (GXUserManager.shared.paramsData?.queryDistance ?? 50) * 1000
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
