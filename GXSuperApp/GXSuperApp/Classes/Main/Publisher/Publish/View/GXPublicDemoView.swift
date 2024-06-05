//
//  GXPublicDemoView.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/9.
//

import UIKit

class GXPublicDemoView: UIView {
    private lazy var contentView: UIView  = {
        return UIView().then {
            $0.backgroundColor = .white
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 16.0
        }
    }()
    
    private lazy var textLabel: UILabel = {
        return UILabel().then {
            $0.textColor = .gx_black
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.font = .gx_boldFont(size: 15)
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

    class func showAlertView(text: String?, imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        let width = SCREEN_WIDTH - 80
        let height = (width - 28) / image.size.width * image.size.height
        let rect = CGRect(x: 0, y: 0, width: width, height: height + 130)
        let view = GXPublicDemoView(frame: rect)
        view.textLabel.text = text
        view.imageView.image = image
        view.show(style: .alert, backgoundTapDismissEnable: true, usingSpring: true)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.textLabel)
        self.addSubview(self.closeButton)

        self.contentView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-56)
        }
        self.textLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalTo(self.imageView.snp.top)
        }
        self.imageView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 60, left: 14, bottom: 14, right: 14))
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
