//
//  GXQRCodeReaderVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/28.
//

import UIKit
import QRCodeReader
import HXPhotoPicker

class GXQRCodeReaderVC: GXBaseViewController {
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var previewView: QRCodeReaderView! {
        didSet {
            previewView.setupComponents(with: QRCodeReaderViewControllerBuilder {
                $0.reader                 = reader
                $0.showTorchButton        = false
                $0.showSwitchCameraButton = false
                $0.showCancelButton       = false
                $0.showOverlayView        = false
                $0.rectOfInterest         = CGRect(x: 0.15, y: 0.2, width: 0.7, height: 0.6)
            })
        }
    }
    lazy var reader: QRCodeReader = {
        return QRCodeReader(metadataObjectTypes: [.qr, .ean13, .ean8, .code39, .code39Mod43, .code93, .code128]).then {
            $0.didFindCode = {[weak self] result in
                guard let `self` = self else { return }
                print("Completion with result: \(result.value) of type \(result.metadataType)")
                let codeType = GXUtil.gx_qrCodeType(qrCode: result.value)
                var value = result.value
                if codeType == .user {
                    value = result.value.replacingOccurrences(of: GXUtil.GXQRCodeType.user.rawValue, with: "")
                }
                else if codeType == .event {
                    value = result.value.replacingOccurrences(of: GXUtil.GXQRCodeType.event.rawValue, with: "")
                }
                else if codeType == .ticket {
                    value = result.value.replacingOccurrences(of: GXUtil.GXQRCodeType.ticket.rawValue, with: "")
                }
                else if codeType == .activity {
                    value = result.value.replacingOccurrences(of: GXUtil.GXQRCodeType.activity.rawValue, with: "")
                }
                self.didFindCodeAction?(codeType, value, self)
            }
        }
    }()

    lazy var scanImageView: UIImageView = {
        return UIImageView(image: UIImage(named: "scan_ic_light")).then {
            $0.autoresizingMask = .flexibleWidth
            $0.frame = CGRect(x: 0, y: 0, width: self.scanView.width, height: 2)
        }
    }()

    var didFindCodeAction: GXActionBlockItem3<GXUtil.GXQRCodeType, String, GXQRCodeReaderVC>?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard checkScanPermissions(), !reader.isRunning else { return }
        self.reader.startScanning()
        self.addScanAnimation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.reader.stopScanning()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.scanView.addSubview(self.scanImageView)
        self.scanImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(-14)
            make.right.equalToSuperview().offset(14)
        }
    }

    private func addScanAnimation() {
        self.scanImageView.layer.removeAllAnimations()
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.isRemovedOnCompletion = false
        animation.duration = 2.5
        animation.fromValue = 0.0
        animation.toValue = self.scanView.frame.height
        animation.repeatCount = MAXFLOAT
        animation.setValue("scanAnimation", forKey: "animationName")
        
        let animation1: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        animation1.isRemovedOnCompletion = false
        animation1.duration = 0.5
        animation1.fromValue = 1.0
        animation1.toValue = 0.0
        animation1.repeatCount = MAXFLOAT
        animation1.beginTime = 2.0
        animation1.setValue("opacityAnimation", forKey: "animationName")
        
        let group = CAAnimationGroup()
        group.animations = [animation, animation1]
        group.duration = 2.5
        group.repeatCount = MAXFLOAT
        
        self.scanImageView.layer.add(group, forKey: nil)
    }

    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch _ as NSError {
            let title = "Camera permission"
            let message = "Your camera permission is not enabled, can not use scan code"
            GXUtil.showAlert(title: title, message: message, cancelTitle: "Disagree", actionTitle: "Agree", handler: { alert, index in
                guard index == 1 else { return }
                DispatchQueue.main.async {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
            })
            return false
        }
    }
    
    /// 图片二维码识别
    private func codeReaderToImage(_ image: UIImage) -> String? {
        let ciImage:CIImage=CIImage(image:image)!
        let context = CIContext(options: nil)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        guard let letDetector = detector else { return nil }
        
        let features = letDetector.features(in: ciImage)
        guard let features = features as? [CIQRCodeFeature] else { return nil }
        
        return features.first?.messageString
    }
}

extension GXQRCodeReaderVC {

    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction func torchButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.reader.toggleTorch(mode: .on)
        }
        else {
            self.reader.toggleTorch(mode: .off)
        }
    }

    @IBAction func photoButtonClicked(_ sender: UIButton) {
        if self.torchButton.isSelected {
            self.torchButtonClicked(self.torchButton)
        }
        var config: PickerConfiguration = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.photoSelectionTapAction = .openEditor
        config.selectMode = .single
        config.selectOptions = .photo
        config.photoList.rowNumber = 3
        config.photoList.allowAddCamera = false
        let vc = PhotoPickerController.init(config: config)
        vc.finishHandler = {[weak self] (result, picker) in
            result.photoAssets.first?.getImage(completion: { image in
                guard let `self` = self else { return }
                guard let letImage = image else { return }
                let value = self.codeReaderToImage(letImage)
                
                print("Completion with result code: \(String(describing: value))")
            })
        }
        self.present(vc, animated: true, completion: nil)
    }
    
}
