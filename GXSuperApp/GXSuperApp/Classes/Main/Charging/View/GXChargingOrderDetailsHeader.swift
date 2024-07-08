//
//  GXChargingOrderDetailsHeader.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/6.
//

import UIKit

class GXChargingOrderDetailsHeader: UIView {
    
    private lazy var iconImgView: UIImageView = {
        return UIImageView(image: UIImage(named: "order_list_ic_done"))
    }()
    
    private lazy var chargingStateLabel: UILabel = {
        return UILabel(frame: .zero).then {
            $0.font = .gx_boldFont(size: 20)
            $0.textColor = .gx_black
            $0.textAlignment = .center
            $0.text = "Charging is Complete"
        }
    }()
    
    private lazy var chargingInfoLabel: UILabel = {
        return UILabel(frame: .zero).then {
            $0.numberOfLines = 0
            $0.font = .gx_font(size: 16)
            $0.textColor = .gx_orange
            $0.textAlignment = .center
            $0.text = "Pending Payment"
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        self.isSkeletonable = true
        self.iconImgView.isSkeletonable = true
        self.chargingStateLabel.isSkeletonable = true
        self.chargingInfoLabel.isSkeletonable = true

        self.addSubview(self.iconImgView)
        self.addSubview(self.chargingStateLabel)
        self.addSubview(self.chargingInfoLabel)
        self.iconImgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 54, height: 54))
        }
        self.chargingStateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.iconImgView.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        self.chargingInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(self.chargingStateLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
    }
    
}
