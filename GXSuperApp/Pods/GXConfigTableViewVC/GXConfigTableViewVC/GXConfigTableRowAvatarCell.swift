//
//  GXConfigTableRowAvatarCell.swift
//  GXConfigTableViewVCSample
//
//  Created by Gin on 2023/11/1.
//

import UIKit

public class GXConfigTableRowAvatarCell: GXConfigTableRowDefaultCell {

    public lazy var avatarImgView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(self.avatarImgView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        guard let letModel = self.model else { return }
        
        var rect = self.avatarImgView.frame
        rect.origin.y = (self.contentView.frame.height - rect.height) * 0.5
        if self.accessoryType != .none {
            rect.origin.x = self.contentView.frame.width - rect.width - 8.0
        } else {
            rect.origin.x = self.contentView.frame.width - letModel.contentMargin - rect.width
        }
        self.avatarImgView.frame = rect

        if let letTextLabel = self.textLabel {
            var textRect = letTextLabel.frame
            textRect.size.width = rect.origin.x - textRect.origin.x - 5.0
            letTextLabel.frame = textRect
        }
    }

    public func bind<T: GXConfigTableRowAvatarModel>(model: T) {
        super.bind(model: model)
        
        self.avatarImgView.frame = CGRect(origin: .zero, size: model.avatarSize)

        model.avatarImage.bind {[weak self] image in
            self?.avatarImgView.image = image
        }.disposed(by: disposeBag)
    }

}
