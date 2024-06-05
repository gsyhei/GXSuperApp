//
//  GXPublishQuestStatsHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/7.
//

import UIKit
import Reusable

class GXPublishQuestStatsHeader: UITableViewHeaderFooterView, Reusable {
    private lazy var tmLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_black
            $0.font = .gx_boldFont(size: 14.0)
            $0.numberOfLines = 0
        }
    }()

    private lazy var containerView: UIView = {
        return UIView().then {
            $0.backgroundColor = .gx_background
        }
    }()

    private lazy var xxLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_drakGray
            $0.font = .gx_boldFont(size: 12.0)
            $0.text = "选项"
        }
    }()

    private lazy var xjLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .center
            $0.textColor = .gx_drakGray
            $0.font = .gx_boldFont(size: 12.0)
            $0.text = "小计"
        }
    }()

    private lazy var blLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .center
            $0.textColor = .gx_drakGray
            $0.font = .gx_boldFont(size: 12.0)
            $0.text = "比例"
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

        self.contentView.addSubview(self.tmLabel)
        self.contentView.addSubview(self.containerView)
        self.tmLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        self.containerView.snp.makeConstraints { make in
            make.top.equalTo(self.tmLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(40)
        }

        self.containerView.addSubview(self.xxLabel)
        self.containerView.addSubview(self.xjLabel)
        self.containerView.addSubview(self.blLabel)
        self.blLabel.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(72)
        }
        self.xjLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalTo(self.blLabel.snp.left)
            make.width.equalTo(72)
        }
        self.xxLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(self.xjLabel.snp.left)
        }
    }
    
    func bindView(model: GXTopicreportsModel?, section: Int) {
        guard let data = model else { return }
        let opName = (data.topicType == 2) ? "【多选】":"【单选】"
        self.tmLabel.text = "\(section + 1)、" + data.topicTitle + opName
    }

}
