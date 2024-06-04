//
//  CameraViewController.swift
//  HXPhotoPicker
//
//  Created by Slience on 2021/8/30.
//

import UIKit
#if HXPICKER_ENABLE_CAMERA_LOCATION
import CoreLocation
#endif
import AVFoundation

/// 需要有导航栏
#if !targetEnvironment(macCatalyst)
open class CameraViewController: BaseViewController {
    public weak var delegate: CameraViewControllerDelegate?
    
    /// 相机配置
    public var config: CameraConfiguration
    /// 相机类型
    public let type: CameraController.CaptureType
    /// 内部自动dismiss
    public var autoDismiss: Bool = true
    
    /// takePhotoMode = .click 拍照类型
    public var takeType: CameraBottomViewTakeType {
        bottomView.takeType
    }
    
    /// 闪光灯模式
    public var flashMode: AVCaptureDevice.FlashMode {
        cameraManager.flashMode
    }
    
    /// 设置闪光灯模式
    @discardableResult
    public func setFlashMode(_ flashMode: AVCaptureDevice.FlashMode) -> Bool {
        cameraManager.setFlashMode(flashMode)
    }
    
    public init(
        config: CameraConfiguration,
        type: CameraController.CaptureType,
        delegate: CameraViewControllerDelegate? = nil
    ) {
        PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
        self.config = config
        self.type = type
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        self.autoDismiss = config.isAutoBack
    }
    private var didLayoutPreview = false
    
    var previewView: CameraPreviewView!
    var cameraManager: CameraManager!
    var bottomView: CameraBottomView!
    var topMaskLayer: CAGradientLayer!
    #if HXPICKER_ENABLE_CAMERA_LOCATION
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var didLocation: Bool = false
    #endif
    
    var firstShowFilterName = true
    var currentZoomFacto: CGFloat = 1
    
    private var requestCameraSuccess = false
    private var sessionCommitConfiguration = true
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
        view.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .white
        initViews()
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            bottomView.isGestureEnable = false
            view.addSubview(bottomView)
            PhotoTools.showConfirm(
                viewController: self,
                title: "相机不可用!".localized,
                message: nil,
                actionTitle: "确定".localized
            ) { [weak self] _ in
                self?.backClick(true)
            }
            return
        }
        AssetManager.requestCameraAccess { isGranted in
            if isGranted {
                self.setupCamera()
            }else {
                self.bottomView.isGestureEnable = false
                self.view.addSubview(self.bottomView)
                PhotoTools.showNotCameraAuthorizedAlert(
                    viewController: self
                ) { [weak self] in
                    self?.backClick(true)
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    private func initViews() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraManager = CameraManager(config: config)
            cameraManager.flashModeDidChanged = { [weak self] in
                guard let self = self else { return }
                self.delegate?.cameraViewController(self, flashModeDidChanged: $0)
            }
            cameraManager.captureDidOutput = { [weak self] pixelBuffer in
                guard let self = self else { return }
                self.previewView.pixelBuffer = pixelBuffer
            }
            
            previewView = CameraPreviewView(
                config: config,
                cameraManager: cameraManager
            )
            previewView.delegate = self
            
            topMaskLayer = PhotoTools.getGradientShadowLayer(true)
            
            #if HXPICKER_ENABLE_CAMERA_LOCATION
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.requestWhenInUseAuthorization()
            #endif
        }
        
        bottomView = CameraBottomView(
            tintColor: config.tintColor,
            takePhotoMode: config.takePhotoMode
        )
        bottomView.delegate = self
    }
    func backClick(_ isCancel: Bool = false) {
        if isCancel {
            delegate?.cameraViewController(didCancel: self)
        }
        if autoDismiss {
            dismiss(animated: true, completion: nil)
        }
    }
    open override func deviceOrientationWillChanged(notify: Notification) {
        guard let previewView = previewView else { return }
        didLayoutPreview = false
        previewView.resetMask(nil)
    }
    open override func deviceOrientationDidChanged(notify: Notification) {
        guard let previewView = previewView else { return }
        previewView.resetOrientation()
        previewView.removeMask(true)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSubviews()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let nav = navigationController else {
            return
        }
        let navHeight = nav.navigationBar.frame.maxY
        nav.navigationBar.setBackgroundImage(
            UIImage.image(
                for: .clear,
                havingSize: CGSize(width: view.width, height: navHeight)
            ),
            for: .default
        )
        nav.navigationBar.shadowImage = UIImage()
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if requestCameraSuccess {
            if config.cameraType == .normal {
                cameraManager.sessionQueue.async {
                    if !self.sessionCommitConfiguration {
                        self.cameraManager.session.commitConfiguration()
                    }
                    self.cameraManager.startRunning(applyQueue: false)
                }
            }
        }
    }
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DispatchQueue.global().async {
            if let sampleBuffer = PhotoManager.shared.sampleBuffer,
               let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
               let imageData = PhotoTools.jpegData(withPixelBuffer: pixelBuffer, attachments: nil) {
                PhotoManager.shared.cameraPreviewImage = UIImage(data: imageData)
                PhotoManager.shared.saveCameraPreview()
                PhotoManager.shared.sampleBuffer = nil
            }
        }
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        if config.cameraType == .normal {
            cameraManager.stopRunning()
        }
        cameraManager.resetFilter()
    }
    
    func layoutSubviews() {
        let previewRect: CGRect
        if UIDevice.isPad || !UIDevice.isPortrait {
            if UIDevice.isPad {
                previewRect = view.bounds
            }else {
                let size = CGSize(width: view.height * 16 / 9, height: view.height)
                previewRect = CGRect(
                    x: (view.width - size.width) * 0.5,
                    y: (view.height - size.height) * 0.5,
                    width: size.width, height: size.height
                )
            }
        }else {
            let size = CGSize(width: view.width, height: view.width / 9 * 16)
            previewRect = CGRect(
                x: (view.width - size.width) * 0.5,
                y: (view.height - size.height) * 0.5,
                width: size.width, height: size.height
            )
        }
        if config.cameraType == .normal, UIImagePickerController.isSourceTypeAvailable(.camera) {
            if !didLayoutPreview && AssetManager.cameraAuthorizationStatus() == .authorized {
                previewView.frame = previewRect
                didLayoutPreview = true
            }
        }
        
        let bottomHeight: CGFloat = 130
        let bottomY: CGFloat
        if UIDevice.isPortrait && !UIDevice.isPad {
            if UIDevice.isAllIPhoneX {
                bottomY = view.height - 110 - previewRect.minY
            }else {
                bottomY = view.height - bottomHeight
            }
        }else {
            bottomY = view.height - bottomHeight
        }
        bottomView.frame = CGRect(
            x: 0,
            y: bottomY,
            width: view.width,
            height: bottomHeight
        )
        if let nav = navigationController, UIImagePickerController.isSourceTypeAvailable(.camera) {
            topMaskLayer.frame = CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: nav.navigationBar.frame.maxY + 10
            )
        }
    }
    
    open override var prefersStatusBarHidden: Bool {
        config.prefersStatusBarHidden
    }
    open override var shouldAutorotate: Bool {
        config.shouldAutorotate
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        config.supportedInterfaceOrientations
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        #if HXPICKER_ENABLE_CAMERA_LOCATION
        if allowLocation && didLocation {
            locationManager.stopUpdatingLocation()
        }
        #endif
        DeviceOrientationHelper.shared.stopDeviceOrientationNotifier()
    }
}

extension CameraViewController {
    
    @objc
    func willEnterForeground() {
    }
    @objc
    func didEnterBackground() {
        previewView.clearMeatalPixelBuffer()
        cameraManager.resetFilter()
    }
    
    @objc
    public func didSwitchCameraClick() {
        previewView.metalView.isPaused = true
        previewView.pixelBuffer = nil
        if config.cameraType == .normal {
            do {
                try cameraManager.switchCameras()
            } catch {
                HXLog("相机前后摄像头切换失败: \(error)")
                switchCameraFailed()
            }
            delegate?.cameraViewController(
                self,
                didSwitchCameraCompletion: cameraManager.activeCamera?.position ?? .unspecified
            )
            if !cameraManager.setFlashMode(config.flashMode) {
                cameraManager.setFlashMode(.off)
            }
        }
        resetZoom()
        previewView.resetOrientation()
        cameraManager.resetFilter()
        previewView.metalView.isPaused = false
    }
    
    func switchCameraFailed() {
        ProgressHUD.showWarning(
            addedTo: view,
            text: "摄像头切换失败!".localized,
            animated: true,
            delayHide: 1.5
        )
    }
    
    func resetZoom() {
        if config.cameraType == .normal {
            cameraManager.zoomFacto = 1
            previewView.effectiveScale = 1
        }
    }
    
    func setupCamera() {
        DeviceOrientationHelper
            .shared
            .startDeviceOrientationNotifier()
        if config.cameraType == .normal {
            view.addSubview(previewView)
        }
        view.addSubview(bottomView)
        cameraManager.sessionQueue.async {
            do {
                self.sessionCommitConfiguration = false
                self.cameraManager.session.beginConfiguration()
                try self.cameraManager.startSession()
                var needAddAudio = false
                switch self.type {
                case .photo:
                    try self.cameraManager.addPhotoOutput()
                case .video:
                    needAddAudio = true
                case .all:
                    try self.cameraManager.addPhotoOutput()
                    needAddAudio = true
                }
                self.cameraManager.addVideoOutput()
                if !needAddAudio {
                    self.addOutputCompletion()
                }else {
                    self.addAudioInput()
                }
            } catch {
                self.cameraManager.session.commitConfiguration()
                DispatchQueue.main.async {
                    PhotoTools.showConfirm(
                        viewController: self,
                        title: "相机初始化失败!".localized,
                        message: nil,
                        actionTitle: "确定".localized
                    ) { [weak self] _ in
                        self?.backClick(true)
                    }
                }
            }
        }
//        DispatchQueue.global().async {
//        }
    }
    
    func addAudioInput() {
        AVCaptureDevice.requestAccess(for: .audio) { isGranted in
            self.cameraManager.sessionQueue.async {
//            DispatchQueue.global().async {
                if isGranted {
                    do {
                        try self.cameraManager.addAudioInput()
                        self.cameraManager.addAudioOutput()
                    } catch {
                        DispatchQueue.main.async {
                            self.addAudioInputFailed()
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        PhotoTools.showAlert(
                            viewController: self,
                            title: "无法使用麦克风".localized,
                            message: "请在设置-隐私-相机中允许访问麦克风".localized,
                            leftActionTitle: "取消".localized,
                            rightActionTitle: "前往系统设置".localized
                        ) { _ in
                            self.addAudioInputFailed()
                        } rightHandler: { _ in
                            PhotoTools.openSettingsURL()
                        }
                    }
                }
                self.addOutputCompletion()
            }
        }
    }
    
    func addAudioInputFailed() {
        ProgressHUD.showWarning(
            addedTo: self.view,
            text: "麦克风添加失败，录制视频会没有声音哦!".localized,
            animated: true,
            delayHide: 1.5
        )
    }
    
    func addOutputCompletion() {
        cameraManager.session.commitConfiguration()
        sessionCommitConfiguration = true
        if config.cameraType == .normal {
            cameraManager.startRunning(applyQueue: false)
        }
        requestCameraSuccess = true
        DispatchQueue.main.async {
            self.previewView.resetOrientation()
            self.sessionCompletion()
        }
    }
    
    func sessionCompletion() {
        if config.cameraType == .normal {
            if cameraManager.canSwitchCameras() {
                addSwithCameraButton()
            }
            previewView.setupGestureRecognizer()
        }else {
            addSwithCameraButton()
        }
        bottomView.addGesture(for: type)
        #if HXPICKER_ENABLE_CAMERA_LOCATION
        startLocation()
        #endif
    }
    
    func addSwithCameraButton() {
        view.layer.addSublayer(topMaskLayer)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: "hx_camera_overturn".image,
            style: .plain,
            target: self,
            action: #selector(didSwitchCameraClick)
        )
    }
}
#endif
