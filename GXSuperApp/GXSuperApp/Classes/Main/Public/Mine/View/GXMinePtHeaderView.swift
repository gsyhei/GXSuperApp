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

class GXMinePtHeaderView: UIView {
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var tagsContentView: UIView!
    @IBOutlet weak var signLabel: UILabel!

    @IBOutlet weak var attentionNumButton: UIButton!
    @IBOutlet weak var fansNumButton: UIButton!
    @IBOutlet weak var collectionsNumButton: UIButton!
    @IBOutlet weak var attentionNumLabel: UILabel!
    @IBOutlet weak var fansNumLabel: UILabel!
    @IBOutlet weak var collectionsNumLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var qrCodeButton: UIButton!

    private var model: GXUserInfoData?
    private var dataSource = ArrayDataSource<String>()
    private weak var superVC: UIViewController?

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

    override func awakeFromNib() {
        super.awakeFromNib()

        self.editButton.setBackgroundColor(.gx_green, for: .normal)
        self.tagsContentView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        if GXUserManager.shared.roleType == .publisher {
            self.attentionNumButton.isHidden = true
            self.fansNumButton.isHidden = true
            self.collectionsNumButton.isHidden = true
            self.attentionNumLabel.isHidden = true
            self.fansNumLabel.isHidden = true
            self.collectionsNumLabel.isHidden = true
        }
    }

    func bindModel(model: GXUserInfoData, superVC: UIViewController?) {
        self.model = model
        self.superVC = superVC
        
        self.avatarButton.kf.setImage(with: URL(string: model.avatarPic), for: .normal, placeholder: .gx_defaultAvatar, completionHandler:  { result in
            switch result {
            case .success(let image):
                self.backImageView.image = UIImage.gx_blurImage(image.image)
            case .failure(_): break
            }
        })
        self.nicknameLabel.text = model.nickName
        self.idLabel.text = "ID: \(model.id)"

        self.signLabel.text = model.personalIntroduction
        self.attentionNumLabel.text = "\(model.followNum)"
        self.fansNumLabel.text = "\(model.fansNum)"
        self.collectionsNumLabel.text = "\(model.favoriteNum)"

        var tags: [String] = []
        // 用户性别 1-男 2-女 0-未知
        if model.userMale == 1 {
            tags.append("男")
        }
        else if model.userMale == 2 {
            tags.append("女")
        }
        if model.vipFlag {
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

extension GXMinePtHeaderView {
    func requestUploadAvatar(image: UIImage) {
        MBProgressHUD.showLoading()
        GXApiUtil.requestUploadAvatar(image: image) { url in
            MBProgressHUD.dismiss()
            GXToast.showSuccess(text: "头像上传成功")
            self.backImageView.image = UIImage.gx_blurImage(image)
            self.avatarButton.setImage(image, for: .normal)
        } failure: { error in
            MBProgressHUD.dismiss()
            MBProgressHUD.showError(error)
        }
    }
}

extension GXMinePtHeaderView {

    @IBAction func avatarButtonClicked(_ sender: UIButton) {
        let action1 = GXAlertAction()
        action1.title = "从手机相册选择"
        action1.titleColor = .gx_black
        action1.titleFont = .gx_boldFont(size: 17)

        let action2 = GXAlertAction()
        action2.title = "拍照"
        action2.titleColor = .gx_black
        action2.titleFont = .gx_boldFont(size: 17)

        GXUtil.showSheet(message: "请选择",
                         otherActions: [action1, action2]) { alert, index in
            if index == 1 {
                var config: PickerConfiguration = PickerConfiguration()
                config.modalPresentationStyle = .fullScreen
                config.selectMode = .single
                config.selectOptions = .photo
                config.photoSelectionTapAction = .openEditor
                config.photoList.allowAddCamera = false
                config.photoList.finishSelectionAfterTakingPhoto = true
                config.photoList.rowNumber = 3
                config.editor.isFixedCropSizeState = true
                config.editor.cropSize.isRoundCrop = false
                config.editor.cropSize.aspectRatios = []
                config.editor.cropSize.aspectRatio = CGSize(width: 1, height: 1)
                config.editor.cropSize.isFixedRatio = true
                config.editor.cropSize.isResetToOriginal = false
                let vc = PhotoPickerController.init(config: config)
                vc.finishHandler = {[weak self] (result, picker) in
                    result.photoAssets.first?.getImage(completion: { image in
                        guard let letImage = image else { return }
                        self?.requestUploadAvatar(image: letImage)
                    })
                }
                self.superVC?.present(vc, animated: true, completion: nil)
            }
            else if index == 2 {
                var config = CameraConfiguration()
                config.modalPresentationStyle = .fullScreen
                config.allowsEditing = true
                config.editor.isFixedCropSizeState = true
                config.editor.cropSize.isRoundCrop = false
                config.editor.cropSize.aspectRatios = []
                config.editor.cropSize.aspectRatio = CGSize(width: 1, height: 1)
                config.editor.cropSize.isFixedRatio = true
                config.editor.cropSize.isResetToOriginal = false
                let vc = CameraController(config: config, type: .photo)
                vc.completion = {[weak self] (result, location) in
                    switch result {
                    case let .image(image):
                        self?.requestUploadAvatar(image: image)
                    default:break
                    }
                }
                self.superVC?.present(vc, animated: true, completion: nil)
            }
        }
    }

    @IBAction func attentionButtonClicked(_ sender: UIButton) {
        let vc = GXMinePtAddFansVC.createVC(selectIndex: 1)
        vc.hidesBottomBarWhenPushed = true
        self.superVC?.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func fansButtonClicked(_ sender: UIButton) {
        let vc = GXMinePtAddFansVC.createVC(selectIndex: 0)
        vc.hidesBottomBarWhenPushed = true
        self.superVC?.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func collectionsButtonClicked(_ sender: UIButton) {
        let vc = GXMinePtCollectVC()
        vc.hidesBottomBarWhenPushed = true
        self.superVC?.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func editButtonClicked(_ sender: UIButton) {
        let vc = GXMinePtEditInfoVC.xibViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.completion = {[weak self] mine in
            self?.superVC?.navigationController?.popViewController(animated: true)
        }
        self.superVC?.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func qrCodeButtonClicked(_ sender: UIButton) {
        guard let userId = self.model?.id else { return }
        GXMinePtQrCodeView.showAlertView(userId: String(userId))
    }

}
