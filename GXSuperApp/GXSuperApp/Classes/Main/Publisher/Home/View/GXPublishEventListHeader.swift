//
//  GXPublishEventListHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/17.
//

import UIKit
import Reusable

class GXPublishEventListHeader: UITableViewHeaderFooterView, Reusable {

    private lazy var titleLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_black
            $0.font = .gx_dingTalkFont(size: 20)
        }
    }()
    
    private lazy var iconIView: UIImageView = {
        return UIImageView(image: UIImage(named: "ax_item_mark")).then {
            $0.isHidden = true
        }
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.iconIView)

        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        self.iconIView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.titleLabel.snp.right).offset(-16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateStatus(isEnd: Bool) {
        if isEnd {
            self.titleLabel.text = "已结束"
            self.titleLabel.textColor = .gx_gray
            self.iconIView.isHidden = true
        }
        else {
            self.titleLabel.text = "进行中"
            self.titleLabel.textColor = .gx_black
            self.iconIView.isHidden = false
        }
    }

}
