//
//  GXPublishMemberSignUpHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/6.
//

import UIKit
import Reusable

class GXPublishMemberSignUpHeader: UITableViewHeaderFooterView, Reusable {
    var allSelectAction: GXActionBlockItem<Bool>?

    private lazy var allSelectButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.titleLabel?.font = .gx_boldFont(size: 12.0)
            $0.setTitle("全选", for: .normal)
            $0.setTitle("取消", for: .selected)
            $0.setTitleColor(.gx_drakGray, for: .normal)
            $0.setTitleColor(.gx_gray, for: .highlighted)
            $0.setTitleColor(.gx_lightGray, for: .disabled)
            $0.addTarget(self, action: #selector(self.allSelectButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    private lazy var bmyhLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_drakGray
            $0.font = .gx_boldFont(size: 12.0)
            $0.text = "报名用户"
        }
    }()

    private lazy var bmrqLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .center
            $0.textColor = .gx_drakGray
            $0.font = .gx_boldFont(size: 12.0)
            $0.text = "报名日期"
        }
    }()

    private lazy var sfjeLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .center
            $0.textColor = .gx_drakGray
            $0.font = .gx_boldFont(size: 12.0)
            $0.text = "实付金额"
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
        self.contentView.backgroundColor = .gx_background

        self.contentView.addSubview(self.allSelectButton)
        self.contentView.addSubview(self.bmyhLabel)
        self.contentView.addSubview(self.bmrqLabel)
        self.contentView.addSubview(self.sfjeLabel)

        self.allSelectButton.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
        self.sfjeLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(72)
        }
        self.bmrqLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalTo(self.sfjeLabel.snp.left)
            make.width.equalTo(94)
        }
        self.bmyhLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(40 + 12)
            make.right.equalTo(self.bmrqLabel.snp.left)
        }
    }

    @objc func allSelectButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.allSelectAction?(sender.isSelected)
    }

    func bindView(activityData: GXActivityBaseInfoData?, isAllSelected: Bool, isAllSelectHidden: Bool = true) {
        // 活动模式 1-免费报名模式 2-卖票模式
        if activityData?.activityMode == 2 || !GXRoleUtil.isTeller(roleType: activityData?.roleType) {
            self.allSelectButton.isHidden = true
            self.bmyhLabel.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(12)
            }
        }
        else {
            self.allSelectButton.isHidden = false
            self.bmyhLabel.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(40 + 12)
            }
        }
        self.allSelectButton.isHidden = isAllSelectHidden
        self.allSelectButton.isSelected = isAllSelected
    }

}
