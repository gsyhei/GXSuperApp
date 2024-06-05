//
//  GXPublishWorkReportCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/22.
//

import UIKit
import Reusable
import CollectionKit
import HXPhotoPicker

class GXPublishWorkReportCell: UITableViewCell, NibReusable {
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var imagesContentView: UIView!
    @IBOutlet weak var collectionViewHLC: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!

    var dataSource = ArrayDataSource<PhotoAsset>()
    var avatarAction: GXActionBlockItem<GXPublishWorkReportCell>?

    private lazy var collectionView: CollectionView = {
        let width: Int = Int(SCREEN_WIDTH - 76.0) / 3
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIImageView, data: PhotoAsset, index: Int) in
            view.contentMode = .scaleAspectFill
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 4.0
            view.kf.setImage(with: data.networkImageAsset?.thumbnailURL, placeholder: UIImage.gx_defaultActivityIcon)
        })
        let sizeSource = { (index: Int, data: PhotoAsset, collectionSize: CGSize) -> CGSize in
            return CGSize(width: width, height: width)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: {[weak self] tapContext in
                guard let `self` = self else { return }
                HXPhotoPicker.PhotoBrowser.show(pageIndex: tapContext.index, transitionalImage: tapContext.view.image) {
                    tapContext.dataSource.numberOfItems
                } assetForIndex: { index in
                    tapContext.dataSource.data(at: index)
                } transitionAnimator: { index in
                    self.collectionView.cell(at: index)
                }
            }
        )
        provider.layout = FlowLayout(spacing: 4.0)
        return CollectionView(provider: provider)
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()

        self.dataSource.data = []
        self.nameLabel.text = nil
        self.avatarButton.setImage(.gx_defaultAvatar, for: .normal)
        self.contentLabel.text = nil
        self.dateLabel.text = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.nameLabel.text = nil
        self.avatarButton.setImage(.gx_defaultAvatar, for: .normal)
        self.contentLabel.text = nil
        self.dateLabel.text = nil
        
        self.imagesContentView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func bindCell(model: GXActivityreportsItem?) {
        guard let item = model else { return }

        self.nameLabel.text = item.creator
        self.avatarButton.kf.setImage(with: URL(string: item.avatarPic ?? ""), for: .normal, placeholder: UIImage.gx_defaultAvatar)
        self.contentLabel.text = item.workProgress
        self.dateLabel.text = item.updateTime

        let photoAsset = PhotoAsset.gx_photoAssets(pics: item.pics)
        let width: Int = Int(SCREEN_WIDTH - 76.0) / 3
        let column = (photoAsset.count + 2) / 3
        let spaceCount = column > 0 ? column - 1 : column
        let height = CGFloat(column * width) + CGFloat(spaceCount) * 4.0
        self.collectionViewHLC.constant = CGFloat(height + 1)
        self.dataSource.data = photoAsset
    }
}

extension GXPublishWorkReportCell {

    @IBAction func avatarButtonClicked(_ sender: UIButton) {
        self.avatarAction?(self)
    }

}
