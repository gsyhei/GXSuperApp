//
//  GXHomeDetailChargingFeeHeader.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/23.
//

import UIKit
import Reusable

class GXHomeDetailChargingFeeHeader: UITableViewHeaderFooterView, Reusable {
    
    private lazy var timeView: UIView = {
        return UIView().then {
            $0.isSkeletonable = true
        }
    }()
    private lazy var kWhView: UIView = {
        return UIView().then {
            $0.isSkeletonable = true
        }
    }()
    private lazy var vipKWhView: UIView = {
        return UIView().then {
            $0.isSkeletonable = true
        }
    }()
    private lazy var feeView: UIView = {
        return UIView().then {
            $0.isSkeletonable = true
        }
    }()

    private lazy var timeLabel: UILabel = {
        return UILabel().then {
            $0.textColor = .gx_textBlack
            $0.font = .gx_font(size: 14)
            $0.text = "Time"
        }
    }()
    
    private lazy var kWhLabel: UILabel = {
        return UILabel().then {
            $0.textColor = .gx_textBlack
            $0.font = .gx_font(size: 14)
            $0.text = "$/kWh"
        }
    }()

    private lazy var vipIconIView: UIImageView = {
        return UIImageView(image: UIImage(named: "details_list_ic_vip"))
    }()
    
    private lazy var vipKWhLabel: UILabel = {
        return UILabel().then {
            $0.textColor = .gx_textBlack
            $0.font = .gx_font(size: 14)
            $0.text = "$/kWh"
        }
    }()

    private lazy var feeLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .right
            $0.textColor = .gx_textBlack
            $0.font = .gx_font(size: 14)
            $0.text = "Idle fee"
        }
    }()    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        self.isSkeletonable = true
        self.backgroundView = UIView(frame: self.bounds)
        self.backgroundView?.backgroundColor = .white

        self.contentView.addSubview(self.timeView)
        self.contentView.addSubview(self.kWhView)
        self.contentView.addSubview(self.vipKWhView)
        self.contentView.addSubview(self.feeView)
        self.timeView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.width.equalTo(108)
        }
        self.kWhView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(self.timeView.snp.right)
            make.width.equalTo(self.vipKWhView)
        }
        self.vipKWhView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(self.kWhView.snp.right)
            make.width.equalTo(self.kWhView)
        }
        self.feeView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(self.vipKWhView.snp.right)
            make.right.equalToSuperview().offset(-12)
            make.width.equalTo(54)
        }
        
        self.timeView.addSubview(self.timeLabel)
        self.kWhView.addSubview(self.kWhLabel)
        self.vipKWhView.addSubview(self.vipIconIView)
        self.vipKWhView.addSubview(self.vipKWhLabel)
        self.feeView.addSubview(self.feeLabel)
        self.timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        self.kWhLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        self.vipIconIView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.size.equalTo(CGSize(width: 28, height: 14))
        }
        self.vipKWhLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.vipIconIView.snp.right).offset(4)
        }
        self.feeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
    }
    
}
