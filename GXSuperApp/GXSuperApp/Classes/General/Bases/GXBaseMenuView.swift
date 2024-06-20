//
//  GXBaseMenuView.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/20.
//

import UIKit

class GXBaseMenuView: UIView {
    
    private(set) lazy var titleLabel: UILabel = {
        return UILabel().then {
            $0.textColor = .gx_textBlack
            $0.font = .gx_semiBoldFont(size: 18)
            $0.text = "Filter"
        }
    }()
    
    private(set) lazy var closeButton: UIButton = {
        return UIButton(type: .custom).then {
            let image = UIImage(named: "scan_nav_ic_close")?.withRenderingMode(.alwaysTemplate)
            $0.setImage(image, for: .normal)
            $0.contentHorizontalAlignment = .right
            $0.tintColor = .gx_drakGray
            $0.addTarget(self, action: #selector(self.closeButtonClicked(_:)), for: .touchUpInside)
        }
    }()
    
    private(set) lazy var topLineView: UIView = {
        return UIView().then {
            $0.backgroundColor = .gx_background
        }
    }()
    
    required init(height: CGFloat) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: height)))
        self.createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closeButtonClicked(_ sender: UIButton) {
        self.hide(animated: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.topLeft, .topRight], radius: 8)
    }
    
    func createSubviews() {
        self.backgroundColor = .white
        self.addSubview(self.titleLabel)
        self.addSubview(self.closeButton)
        self.addSubview(self.topLineView)
        
        self.topLineView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(48)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(0.5)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(self.topLineView.snp.top)
            make.left.equalToSuperview().offset(15)
        }
        self.closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(self.topLineView.snp.top)
            make.right.equalToSuperview()
            make.width.equalTo(44)
        }
    }
    
}
