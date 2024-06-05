//
//  GXVerticalCalendarDayHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/9.
//

import UIKit
import Reusable

class GXVerticalCalendarDayHeader: UICollectionReusableView, Reusable {

    public lazy var dateLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.textColor = .gx_textBlack
        label.font = .gx_boldFont(size: 13)

        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .gx_background
        self.addSubview(self.dateLabel)
        self.dateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
