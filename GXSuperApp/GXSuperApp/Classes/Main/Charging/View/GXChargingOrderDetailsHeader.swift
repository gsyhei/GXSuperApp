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
            $0.text = "Charging Completed"
        }
    }()
    
    private lazy var chargingInfoLabel: UILabel = {
        return UILabel(frame: .zero).then {
            $0.numberOfLines = 0
            $0.font = .gx_font(size: 16)
            $0.textColor = .gx_orange
            $0.textAlignment = .center
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
    
    func bindView(model: GXChargingOrderDetailData?) {
        guard let model = model else { return }
        
        switch model.orderStatus {
        case .OCCUPY:
            self.chargingInfoLabel.textColor = .gx_orange
            if let occupyStartTime = GXUserManager.shared.paramsData?.occupyStartTime,
                model.countdown > 0, model.countdown <= occupyStartTime * 60 {
                self.chargingInfoLabel.text = "Occupied"
            }
            else {
                self.chargingInfoLabel.text = "Occupied - Please remove the vehicle from the charging area to avoid incurring the idle fee"
            }
        case .PAYMENT:
            self.chargingInfoLabel.textColor = .gx_drakGray
            self.chargingInfoLabel.text = nil
        case .TO_PAY:
            self.chargingInfoLabel.textColor = .gx_orange
            self.chargingInfoLabel.text = "Pending Payment"
        case .FINISHED:
            self.chargingInfoLabel.textColor = .gx_drakGray
            self.chargingInfoLabel.text = "Thank you for choosing the MarsEnergy app"
        case .CHARGING:
            self.chargingInfoLabel.textColor = .gx_drakGray
            self.chargingInfoLabel.text = "Charging..."
        default:break
        }
    }
    
}
