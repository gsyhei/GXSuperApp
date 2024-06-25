//
//  GXHomeFilterCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/20.
//

import UIKit
import Reusable

class GXHomeFilterCell: UICollectionViewCell, Reusable {
    
    private(set) lazy var nameLabel: UILabel = {
        return UILabel().then {
            $0.backgroundColor = .gx_background
            $0.textAlignment = .center
            $0.textColor = .gx_drakGray
            $0.font = .gx_font(size: 14)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 16
            $0.text = "Favorite Stations"
        }
    }()
    
    var isChecked: Bool = false {
        didSet {
            self.nameLabel.backgroundColor = isSelected ? .gx_green : .gx_background
            self.nameLabel.textColor = isSelected ? .white : .gx_drakGray
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
    }
    
    private func createSubviews() {
        self.contentView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

class GXHomeFilterHeader: UICollectionReusableView, Reusable {
    private(set) lazy var titleLabel: UILabel = {
        return UILabel().then {
            $0.backgroundColor = .white
            $0.textAlignment = .left
            $0.textColor = .gx_textBlack
            $0.font = .gx_boldFont(size: 16)
            $0.text = "My Preferences"
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
    }
    
    private func createSubviews() {
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
