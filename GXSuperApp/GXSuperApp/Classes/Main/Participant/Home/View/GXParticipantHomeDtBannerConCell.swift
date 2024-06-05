//
//  GXParticipantHomeDtBannerCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/7.
//

import UIKit
import HXPhotoPicker

class GXParticipantHomeDtBannerConCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        return UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 96)).then {
            $0.contentMode = .scaleAspectFill
        }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
        self.contentView.backgroundColor = .white
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 12.0
        
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindCell(model: GXPtHomeListBannerItem) {
        self.imageView.kf.setImage(with: URL(string: model.bannerPic))
    }

    func bindModel(urlString: String) {
        self.contentView.layer.masksToBounds = false
        self.contentView.layer.cornerRadius = 0.0
        self.imageView.kf.setImage(with: URL(string: urlString), placeholder: UIImage.gx_defaultActivityIcon)
    }

    func bindModel(asset: PhotoAsset) {
        self.contentView.layer.masksToBounds = false
        self.contentView.layer.cornerRadius = 0.0
        let url = asset.networkImageAsset?.originalURL
        self.imageView.kf.setImage(with: url, placeholder: UIImage.gx_defaultActivityIcon)
    }

}
