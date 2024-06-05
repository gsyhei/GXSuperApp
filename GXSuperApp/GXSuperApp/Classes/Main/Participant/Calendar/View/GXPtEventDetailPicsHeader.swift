//
//  GXPtEventDetailPicsHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/1.
//

import UIKit
import Reusable

class GXPtEventDetailPicsHeader: UITableViewHeaderFooterView, Reusable {

    lazy var infoLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_black
            $0.font = .gx_font(size: 14.0)
            $0.numberOfLines = 0
        }
    }()

    lazy var lineView: UIView = {
        return UIView().then {
            $0.backgroundColor = .gx_background
        }
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.backgroundView = nil
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.infoLabel)
        self.contentView.addSubview(self.lineView)

        self.lineView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(1)
        }
        self.infoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindView(model: GXPublishEventStepData?) {
        guard let model = model else { return }
        self.infoLabel.text = model.eventPicsDesc
    }

    func bindView(text: String?, isShowLine: Bool) {
        self.infoLabel.text = text
        self.lineView.isHidden = !isShowLine
    }

}
