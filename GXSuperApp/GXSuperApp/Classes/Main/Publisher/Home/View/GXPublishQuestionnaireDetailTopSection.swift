//
//  GXPublishQuestionnaireDetailTopSection.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/24.
//

import UIKit
import Reusable

class GXPublishQuestionnaireDetailTopSection: UITableViewHeaderFooterView, Reusable {
    
    private lazy var numberLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_black
            $0.font = .gx_boldFont(size: 14.0)
        }
    }()

    private lazy var titleLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_black
            $0.font = .gx_boldFont(size: 14.0)
            $0.numberOfLines = 0
        }
    }()

    private lazy var detailLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_gray
            $0.font = .gx_font(size: 12.0)
            $0.numberOfLines = 0
        }
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.createSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSubviews() {
        self.backgroundView = nil
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.numberLabel)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.detailLabel)

        self.numberLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
        }
        self.numberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.numberLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.numberLabel.sizeToFit()

        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(self.numberLabel.snp.right)
            make.right.equalToSuperview().offset(-16)
        }
        self.detailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(2)
            make.left.equalTo(self.titleLabel)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-6)
        }
    }

    func bindView(model: GXQuestionairetopicsModel?, section: Int) {
        self.numberLabel.text = "\(section)、"
        self.numberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.numberLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.numberLabel.sizeToFit()
        
        let opName = (model?.topicType == 2) ? "【多选】":"【单选】"
        self.titleLabel.text = (model?.topicTitle ?? "") + opName
        self.detailLabel.text = model?.topicDesc
    }

}
