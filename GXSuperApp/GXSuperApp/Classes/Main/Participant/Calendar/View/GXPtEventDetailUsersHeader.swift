//
//  GXPtEventDetailUsersHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/1.
//

import UIKit
import Reusable

class GXPtEventDetailUsersHeader: UITableViewHeaderFooterView, Reusable {

    private lazy var rankLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_gray
            $0.font = .gx_font(size: 13.0)
            $0.text = "报名用户"
        }
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.backgroundView = nil
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.rankLabel)
        self.rankLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
