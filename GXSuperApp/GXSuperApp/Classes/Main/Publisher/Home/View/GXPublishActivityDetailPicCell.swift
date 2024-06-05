//
//  GXPublishActivityDetailPicCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/14.
//

import UIKit
import Reusable
import HXPhotoPicker

class GXPublishActivityDetailPicCell: UITableViewCell, Reusable {
    lazy var picImageView: UIImageView = {
        return UIImageView(frame: .zero).then {
            $0.contentMode = .scaleAspectFill
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8.0
        }
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        self.contentView.addSubview(self.picImageView)
        self.picImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    class func height(asset: PhotoAsset) -> CGFloat {
        guard let image = asset.localImageAsset?.image else { return 200.0 }
        let scale = image.size.height / image.size.width
        return (SCREEN_WIDTH - 32.0) * scale + 16.0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.picImageView.image = UIImage.gx_defaultActivityIcon
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.picImageView.image = UIImage.gx_defaultActivityIcon
    }

    func bindModel(urlString: String) {
        self.picImageView.kf.setImage(with: URL(string: urlString), placeholder: UIImage.gx_defaultActivityIcon)
    }
    
    func bindModel(asset: PhotoAsset, loadCompletion: GXActionBlock?) {
        if let image = asset.localImageAsset?.image {
            self.picImageView.image = image
            return
        }
        self.picImageView.image = UIImage.gx_defaultActivityIcon
        asset.getImage {[weak self] image in
            self?.picImageView.image = image
            if let letImage = image {
                asset.localImageAsset = LocalImageAsset(letImage)
            }
            loadCompletion?()
        }
    }

}
