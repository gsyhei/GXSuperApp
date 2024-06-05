//
//  GXPublishReviewListCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/22.
//

import UIKit
import Reusable
import CollectionKit
import HXPhotoPicker

class GXPublishReviewListCell: UITableViewCell, NibReusable {
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var imagesContentView: UIView!
    @IBOutlet weak var collectionViewHLC: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var settopButton: UIButton!
    @IBOutlet weak var settopButtonWLC: NSLayoutConstraint!
    @IBOutlet weak var settopButtonRLC: NSLayoutConstraint!

    var dataSource = ArrayDataSource<PhotoAsset>()
    var avatarAction: GXActionBlockItem<GXPublishReviewListCell>?
    var moreAction: GXActionBlockItem<GXPublishReviewListCell>?
    var optionAction: GXActionBlockItem2<GXPublishReviewListCell, String?>?

    private lazy var collectionView: CollectionView = {
        let width: Int = Int(SCREEN_WIDTH - 76.0) / 3
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIImageView, data: PhotoAsset, index: Int) in
            view.contentMode = .scaleAspectFill
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 4.0
            view.kf.setImage(with: data.networkImageAsset?.thumbnailURL)
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

    func bindCell(model: GXActivityreviewsListItem?) {
        guard let item = model else { return }

        self.nameLabel.text = item.nickName
        self.avatarButton.kf.setImage(with: URL(string: item.avatarPic ?? ""), for: .normal)
        self.contentLabel.text = item.reviewTitle
        self.dateLabel.text = item.updateTime

        let photoAsset = PhotoAsset.gx_photoAssets(pics: item.reviewPics)
        let width: Int = Int(SCREEN_WIDTH - 76.0) / 3
        let column = (photoAsset.count + 2) / 3
        let spaceCount = column > 0 ? column - 1 : column
        let height = CGFloat(column * width) + CGFloat(spaceCount) * 4.0
        self.collectionViewHLC.constant = CGFloat(height + 1)
        self.dataSource.data = photoAsset

        //回顾状态 0-待审核 1-审核通过/上架/启用 2-审核未通过/禁用 3-平台禁用
        let reviewStatus = item.reviewStatus ?? 0
        switch reviewStatus {
        case 0:
            self.statusLabel.text = "待审核"
            self.statusLabel.textColor = .gx_yellow

            self.settopButtonRLC.constant = 76
            self.leftButton.isHidden = false
            self.leftButton.setTitle("启用", for: .normal)
            self.leftButton.gx_setGreenButton()

            self.rightButton.isHidden = false
            self.rightButton.setTitle("禁用", for: .normal)
            self.rightButton.gx_setRedBorderButton()

            self.settopButton.isHidden = true
        case 1:
            self.statusLabel.text = "已启用"
            self.statusLabel.textColor = .gx_drakGreen
            
            if let userId = model?.userId, GXUserManager.shared.user?.id == userId {
                self.settopButtonRLC.constant = 76
                self.leftButton.isHidden = false
                self.leftButton.setTitle("编辑", for: .normal)
                self.leftButton.gx_setGrayButton()
            }
            else {
                self.settopButtonRLC.constant = 8
                self.leftButton.isHidden = true
            }

            self.rightButton.isHidden = false
            self.rightButton.setTitle("禁用", for: .normal)
            self.rightButton.gx_setRedBorderButton()

            self.settopButton.isHidden = false
            let settopTitle = (item.setTop == 1) ? "取消置顶":"置顶"
            let settopWLC = (item.setTop == 1) ? 80.0:60.0
            self.settopButtonWLC.constant = settopWLC
            self.settopButton.setTitle(settopTitle, for: .normal)
            self.settopButton.gx_setGrayButton()
        case 2:
            self.statusLabel.text = "已禁用"
            self.statusLabel.textColor = .gx_red

            if let userId = model?.userId, GXUserManager.shared.user?.id == userId {
                self.settopButtonRLC.constant = 76
                self.leftButton.isHidden = false
                self.leftButton.setTitle("编辑", for: .normal)
                self.leftButton.gx_setGrayButton()
            }
            else {
                self.settopButtonRLC.constant = 8
                self.leftButton.isHidden = true
            }

            self.rightButton.isHidden = false
            self.rightButton.setTitle("启用", for: .normal)
            self.rightButton.gx_setGreenButton()

            self.settopButton.isHidden = true
        case 3:
            self.statusLabel.text = "平台禁用"
            self.statusLabel.textColor = .gx_red

            self.settopButtonRLC.constant = 8
            self.leftButton.isHidden = true
            self.rightButton.isHidden = true
            self.settopButton.isHidden = true
        default: break
        }
    }
    
}

extension GXPublishReviewListCell {

    @IBAction func avatarButtonClicked(_ sender: UIButton) {
        self.avatarAction?(self)
    }

    @IBAction func moreButtonClicked(_ sender: UIButton) {
        self.moreAction?(self)
    }

    @IBAction func leftButtonClicked(_ sender: UIButton) {
        self.optionAction?(self, sender.title(for: .normal))
    }

    @IBAction func rightButtonClicked(_ sender: UIButton) {
        self.optionAction?(self, sender.title(for: .normal))
    }

    @IBAction func settopButtonClicked(_ sender: UIButton) {
        self.optionAction?(self, sender.title(for: .normal))
    }
}
