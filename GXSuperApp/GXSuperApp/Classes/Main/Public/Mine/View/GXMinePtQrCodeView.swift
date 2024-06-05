//
//  GXMinePtQrCodeView.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/9.
//

import UIKit

class GXMinePtQrCodeView: UIView {
    private lazy var contentView: UIView  = {
        return UIView().then {
            $0.backgroundColor = .white
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 16.0
        }
    }()

    private lazy var imageView: UIImageView = {
        return UIImageView().then {
            $0.backgroundColor = .hex(hexString: "#D8D8D8")
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8.0
        }
    }()

    private lazy var closeButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.setImage(UIImage(named: "m_qrcode_close"), for: .normal)
            $0.addTarget(self, action: #selector(closeButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    private var userId: String? {
        didSet {
            guard let userId = userId else { return }
            let qrCodeString = GXUtil.gx_qrCode(type: .user, text: userId)
            UIImage.createQRCodeImage(text: qrCodeString) {[weak self] image in
                self?.imageView.image = image
            }
        }
    }

    private func setQRCode(type: GXUtil.GXQRCodeType, text: String?) {
        let qrCodeString = GXUtil.gx_qrCode(type: type, text: text)
        UIImage.createQRCodeImage(text: qrCodeString) {[weak self] image in
            self?.imageView.image = image
        }
    }

    class func showAlertView(userId: String?) {
        let width = SCREEN_WIDTH - 160
        let rect = CGRect(x: 0, y: 0, width: width, height: width + 56)
        let qrcodeView = GXMinePtQrCodeView(frame: rect)
        qrcodeView.userId = userId
        qrcodeView.show(style: .alert, backgoundTapDismissEnable: false, usingSpring: true)
    }

    class func showAlertView(type: GXUtil.GXQRCodeType, text: String?) {
        let width = SCREEN_WIDTH - 160
        let rect = CGRect(x: 0, y: 0, width: width, height: width + 56)
        let qrcodeView = GXMinePtQrCodeView(frame: rect)
        qrcodeView.setQRCode(type: type, text: text)
        qrcodeView.show(style: .alert, backgoundTapDismissEnable: false, usingSpring: true)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.imageView)
        self.addSubview(self.closeButton)

        self.contentView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.snp.width)
        }
        self.imageView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
        }
        self.closeButton.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.bottom)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func closeButtonClicked(_ sender: UIButton) {
        self.hide(animated: true)
    }

}
