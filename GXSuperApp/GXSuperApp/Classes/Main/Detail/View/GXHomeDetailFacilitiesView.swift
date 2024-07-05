//
//  GXHomeDetailFacilitiesView.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit

class GXHomeDetailFacilitiesView: UIView {

    lazy var iconIView: UIImageView = {
        return UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
    }()
    
    lazy var nameLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .center
            $0.textColor = .gx_drakGray
            $0.font = .gx_font(size: 15)
        }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.iconIView)
        self.addSubview(self.nameLabel)
        self.iconIView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        self.nameLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
