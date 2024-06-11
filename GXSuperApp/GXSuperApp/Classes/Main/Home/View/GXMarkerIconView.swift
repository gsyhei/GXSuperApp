//
//  GXMarkerIconView.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/8.
//

import UIKit

class GXMarkerIconView: UIView {
    private lazy var titleLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_textBlack
            $0.text = "$1.55"
            $0.font = .gx_semiBoldFont(size: 20)
        }
    }()
    private lazy var bottomView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 76, height: 16)).then {
            $0.backgroundColor = .gx_lightBlue
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 3.0
        }
    }()
    private lazy var numberLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .center
            $0.textColor = .gx_blue
            $0.text = "18/20"
            $0.font = .gx_font(size: 13)
        }
    }()
    private lazy var tagImageView: UIImageView = {
        return UIImageView(image: UIImage(named: "home_map_ic_fast_normal"))
    }()
    
    class func createIconView() -> GXMarkerIconView {
        return GXMarkerIconView(frame: CGRect(x: 0, y: 0, width: 80, height: 46))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 6.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.gx_lightGray.cgColor
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.bottomView)
        self.bottomView.addSubview(self.tagImageView)
        self.bottomView.addSubview(self.numberLabel)
        self.bottomView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(16)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalTo(self.bottomView.snp.top)
        }
        self.tagImageView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(31)
        }
        self.numberLabel.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(self.tagImageView.snp.right)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateNumber(title: String) {
        self.numberLabel.text = title
        let width = title.width(font: self.numberLabel.font)
        self.frame.size.width = width + 58
    }
    
}
