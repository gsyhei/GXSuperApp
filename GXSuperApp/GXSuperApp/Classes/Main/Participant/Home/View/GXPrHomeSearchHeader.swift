//
//  GXPrHomeSearchHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/28.
//

import UIKit
import Reusable

class GXPrHomeSearchHeader: UITableViewHeaderFooterView, Reusable {
    var deleteAction: GXActionBlock?

    private lazy var deleteButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.contentHorizontalAlignment = .right
            $0.setImage(UIImage(named: "a_delete_icon"), for: .normal)
            $0.addTarget(self, action: #selector(self.deleteButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    private lazy var titleButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.setTitleColor(.gx_black, for: .normal)
            $0.titleLabel?.font = .gx_boldFont(size: 14)
            $0.isUserInteractionEnabled = false
        }
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleButton.imageLocationAdjust(model: .left, spacing: 4.0)
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.backgroundView = nil
        self.contentView.backgroundColor = .white

        self.contentView.addSubview(self.titleButton)
        self.contentView.addSubview(self.deleteButton)
        self.deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        self.titleButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindView(title: String?, image: UIImage? = nil, isDelete: Bool = false) {
        self.titleButton.setTitle(title, for: .normal)
        self.titleButton.setImage(image, for: .normal)
        self.deleteButton.isHidden = !isDelete
    }
}

extension GXPrHomeSearchHeader {
    @objc func deleteButtonClicked(_ sender: UIButton) {
        self.deleteAction?()
    }
}
