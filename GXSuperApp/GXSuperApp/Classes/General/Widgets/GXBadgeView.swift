//
//  GXBadgeView.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/8/4.
//

import UIKit
import Then
import SnapKit

class GXBadgeView: UIView {
    var badge: Int = 0 {
        didSet {
            self.isHidden = self.badge == 0
            guard badge > 0 else { return }
            self.badgeLabel.text = (badge > 99) ? "99+":String(badge)
        }
    }
    
    lazy var badgeLabel: UILabel = {
        return UILabel().then {
            $0.backgroundColor = .gx_red
            $0.textColor = .white
            $0.textAlignment = .center
            $0.font = .gx_boldFont(size: 15)
        }
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.height/2
    }

    override convenience init(frame: CGRect) {
        self.init(frame: frame)
        self.createSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.createSubviews()
    }
    
    private func createSubviews() {
        self.layer.masksToBounds = true
        self.addSubview(self.badgeLabel)
        self.badgeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }
    }
    
}
