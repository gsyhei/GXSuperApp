//
//  GXPtEventDetailTopHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/1.
//

import UIKit
import Reusable

class GXPtEventDetailMapsHeader: UITableViewHeaderFooterView, Reusable {

    private lazy var descLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_black
            $0.font = .gx_font(size: 14.0)
            $0.numberOfLines = 0
        }
    }()

    private lazy var lineView: UIView = {
        return UIView().then {
            $0.backgroundColor = .gx_background
        }
    }()

    private lazy var dateIView: UIImageView = {
        return UIImageView(image: UIImage(named: "pt_event_time"))
    }()
    private lazy var dateLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_black
            $0.font = .gx_font(size: 14.0)
        }
    }()

    private lazy var addrssIView: UIImageView = {
        return UIImageView(image: UIImage(named: "pt_event_location"))
    }()
    private lazy var addrssLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_black
            $0.font = .gx_font(size: 14.0)
            $0.numberOfLines = 0
        }
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.backgroundView = nil
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.descLabel)
        self.contentView.addSubview(self.lineView)
        self.contentView.addSubview(self.dateIView)
        self.contentView.addSubview(self.dateLabel)
        self.contentView.addSubview(self.addrssIView)
        self.contentView.addSubview(self.addrssLabel)

        self.descLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        self.lineView.snp.makeConstraints { make in
            make.top.equalTo(self.descLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(1)
        }
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.lineView.snp.bottom).offset(12)
            make.left.equalTo(self.dateIView.snp.right).offset(2)
            make.right.equalToSuperview().offset(-16)
        }
        self.dateIView.snp.makeConstraints { make in
            make.centerY.equalTo(self.dateLabel)
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        self.addrssLabel.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(12)
            make.left.equalTo(self.addrssIView.snp.right).offset(2)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-4)
        }
        self.addrssIView.snp.makeConstraints { make in
            make.centerY.equalTo(self.addrssLabel)
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindView(model: GXPublishEventStepData?) {
        guard let model = model else { return }
        self.descLabel.text = model.eventDesc
        self.dateLabel.text = model.startToEndDateString()
        self.addrssLabel.text = model.address
        self.addrssIView.isHidden = (model.address?.count ?? 0) == 0
    }

}
