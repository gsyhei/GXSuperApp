//
//  GXHomeVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/6.
//

import UIKit
import GoogleMaps

class GXHomeVC: GXBaseViewController {
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var ongoingView: UIView!
    @IBOutlet weak var ongoingButton: UIButton!
    
    private lazy var panView: GXHomePanView = {
        return GXHomePanView(frame: self.view.bounds).then {
            $0.backgroundColor = .gx_background
        }
    }()
    
    lazy var mapView: GMSMapView = {
        let camera = GMSCameraPosition(latitude: -33.868, longitude: 151.2086, zoom: 12)
        return GMSMapView(frame: .zero, camera: camera).then {
            $0.delegate = self
            $0.settings.compassButton = true
            $0.settings.myLocationButton = false
            $0.padding = .zero
            $0.isMyLocationEnabled = true
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
        
        let top = self.topContainerView.height + self.view.safeAreaInsets.top + 22.0
        let width = self.view.bounds.width
        let height = self.view.bounds.height - top - self.view.safeAreaInsets.bottom
        let panTopY = top
        let panCenterY = top - 12.0 + height/2
        let panBottomY = top + height - 156.0
        self.panView.frame = CGRect(x: 0, y: top, width: width, height: height)
        self.panView.setPanMovedY(top: panTopY, center: panCenterY, bottom: panBottomY)
        
        let mapTop = top - 22.0
        let mapHeight = panBottomY - mapTop + 30.0
        self.mapView.frame = CGRect(x: 0, y: mapTop, width: width, height: mapHeight)
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
        
        self.view.insertSubview(self.mapView, belowSubview: self.myLocationButton)
        self.view.insertSubview(self.panView, aboveSubview: self.myLocationButton)
    }
    
}

private extension GXHomeVC {
    
    @IBAction func searchButtonClicked(_ sender: Any?) {
        
    }
    
    @IBAction func filterButtonClicked(_ sender: Any?) {
        
    }
    
    @IBAction func myLocationButtonClicked(_ sender: Any?) {
        guard let location = mapView.myLocation, CLLocationCoordinate2DIsValid(location.coordinate) else {
            return
        }
        mapView.layer.cameraLatitude = location.coordinate.latitude
        mapView.layer.cameraLongitude = location.coordinate.longitude
        mapView.layer.cameraBearing = 0
    }
    
    @IBAction func ongoingButtonClicked(_ sender: Any?) {
        
    }
    
    func addMapViewAnimation(key: String, toValue: Double) {
        let animation = CABasicAnimation(keyPath: key)
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.toValue = toValue
        mapView.layer.add(animation, forKey: key)
    }
}

extension GXHomeVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapMyLocation location: CLLocationCoordinate2D) {
        
    }
}
