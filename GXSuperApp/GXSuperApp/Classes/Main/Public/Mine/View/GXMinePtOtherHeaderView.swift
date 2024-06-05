//
//  GXMinePtHeaderView.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/28.
//

import UIKit
import Kingfisher
import CollectionKit
import HXPhotoPicker
import MBProgressHUD

class GXMinePtOtherHeaderView: UIView {
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var tagsContentView: UIView!
    @IBOutlet weak var signLabel: UILabel!

    @IBOutlet weak var fansNumLabel: UILabel!
    @IBOutlet weak var attentionButton: UIButton!

    private var dataSource = ArrayDataSource<String>()
    private weak var superVC: UIViewController?
    var avatarAction: GXActionBlock?
    var attentionAction: GXActionBlock?

    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: String, index: Int) in
            view.titleLabel?.font = .gx_font(size: 10)
            view.setTitleColor(.white, for: .normal)
            view.backgroundColor = UIColor(white: 1, alpha: 0.17)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 8.0
            view.isUserInteractionEnabled = false
            if data == "男" {
                view.setImage(UIImage(named: "m_boy_icon"), for: .normal)
                view.imageLocationAdjust(model: .left, spacing: 2.0)
            } else if data == "女" {
                view.setImage(UIImage(named: "m_girl_icon"), for: .normal)
                view.imageLocationAdjust(model: .left, spacing: 2.0)
            } else {
                view.setImage(nil, for: .normal)
            }
            view.setTitle(data, for: .normal)
        })
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
            var width = data.width(font: .gx_font(size: 10)) + 12.0
            if data == "男" || data == "女" {
                width += 10.0
            }
            return CGSize(width: width, height: 16)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource
        )
        provider.layout = RowLayout(spacing: 4.0)
        return CollectionView(provider: provider)
    }()

    class func getHeaderHeight(text: String?) -> CGFloat {
        let textHeight = (text ?? "").height(width: SCREEN_WIDTH-48, font: .gx_font(size: 14))
        return 280 + textHeight
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.attentionButton.setBackgroundColor(.gx_green, for: .normal)
        self.attentionButton.setTitle("已关注", for: .selected)
        self.tagsContentView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func bindModel(model: GXUserHomepageData?) {
        guard let model = model else { return }

        self.avatarButton.kf.setImage(with: URL(string: model.avatarPic), for: .normal, placeholder: .gx_defaultAvatar, completionHandler:  { result in
            switch result {
            case .success(let image):
                self.backImageView.image = UIImage.gx_blurImage(image.image)
            case .failure(_): break
            }
        })
        self.nicknameLabel.text = model.nickName
        self.idLabel.text = "ID: \(model.userId)"

        self.signLabel.text = model.personalIntroduction
        self.fansNumLabel.text = "\(model.fansNum)"
        
        let isSelf: Bool = GXUserManager.shared.user?.id == Int(model.userId)
        self.attentionButton.isHidden = isSelf || (GXUserManager.shared.roleType == .publisher)
        if !self.attentionButton.isHidden {
            if model.fansFlag == 1 {
                self.attentionButton.gx_setSelectedGrayButton()
            } else {
                self.attentionButton.gx_setGreenButton()
            }
        }
        var tags: [String] = []
        // 用户性别 1-男 2-女 0-未知
        if model.userMale == 1 {
            tags.append("男")
        }
        else if model.userMale == 2 {
            tags.append("女")
        }
        if model.vipFlag == 1 {
            tags.append("VIP")
        }
        if model.realnameFlag == 1 {
            tags.append("实名")
        }
        if model.expertFlag == 1 {
            tags.append("达人")
        }
        if model.officialFlag == 1 {
            tags.append("官方认证")
        }
        if model.orgAccreditationFlag == 1 {
            tags.append("机构认证")
        }
        self.dataSource.data = tags
    }
}

extension GXMinePtOtherHeaderView {

    @IBAction func avatarButtonClicked(_ sender: UIButton) {
        self.avatarAction?()
    }

    @IBAction func attentionButtonClicked(_ sender: UIButton) {
        self.attentionAction?()
    }

}
