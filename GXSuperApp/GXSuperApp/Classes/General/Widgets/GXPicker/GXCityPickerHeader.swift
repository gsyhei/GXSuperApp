//
//  GXCityPickerHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/26.
//

import UIKit
import Reusable

class GXCityPickerHeader: UITableViewHeaderFooterView, Reusable {
    public lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .left
        label.textColor = .gx_black
        label.font = .gx_font(size: 14)

        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.backgroundView = nil
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
