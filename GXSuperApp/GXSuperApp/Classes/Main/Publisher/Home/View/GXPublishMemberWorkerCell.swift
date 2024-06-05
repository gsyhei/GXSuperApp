//
//  GXPublishMemberWorkerCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/4.
//

import UIKit
import Reusable
import CollectionKit

class GXPublishMemberWorkerCell: UITableViewCell, NibReusable {
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var labsCollectionView: CollectionView!
    @IBOutlet weak var btnsCollectionView: CollectionView!

    var labsDataSource = ArrayDataSource<String>()
    var btnsDataSource = ArrayDataSource<String>()
    var buttonAction: GXActionBlockItem2<GXPublishMemberWorkerCell, String>?
    var avatarAction: GXActionBlockItem<GXPublishMemberWorkerCell>?
    var myRoleType: String?

    private lazy var labsProvider: BasicProvider<String, UILabel> = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UILabel, data: String, index: Int) in
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 8.0
            view.textAlignment = .center
            view.font = .gx_font(size: 10)
            view.textColor = .white
            view.text = data
            switch data {
            case "发布者":
                view.backgroundColor = .gx_blue
            case "管理员":
                view.backgroundColor = .gx_blue
            case "客服":
                view.backgroundColor = .gx_yellow
            case "核销票":
                view.backgroundColor = .gx_drakGreen
            default: break
            }
        })
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
            var width = data.width(font: .gx_font(size: 10)) + 12.0
            return CGSize(width: width, height: collectionSize.height)
        }
        let provider = BasicProvider (
            dataSource: self.labsDataSource,
            viewSource: viewSource,
            sizeSource: sizeSource
        )
        provider.layout = RowLayout(spacing: 8.0)

        return provider
    }()

    private lazy var btnsProvider: BasicProvider<String, UIButton> = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: String, index: Int) in
            view.titleLabel?.font = .gx_font(size: 15)
            view.setTitle(data, for: .normal)
            view.setBackgroundColor(.white, for: .normal)
            view.setBackgroundColor(.gx_lightGray, for: .highlighted)
            if data == "移除" {
                view.setTitleColor(.gx_red, for: .normal)
            } else {
                view.setTitleColor(.gx_blue, for: .normal)
            }
            view.setTitleColor(.gx_gray, for: .disabled)
            view.isEnabled = GXRoleUtil.isAdmin(roleType: self.myRoleType)
            view.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        })
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
            if data == "移除" {
                return CGSize(width: 60, height: collectionSize.height)
            }
            else {
                if self.btnsDataSource.data.last == "移除" && self.btnsDataSource.data.count > 1 {
                    let width = (collectionSize.width - 60.0) / CGFloat(self.btnsDataSource.data.count - 1)
                    return CGSize(width: width, height: collectionSize.height)
                }
                else {
                    let width = collectionSize.width / CGFloat(self.btnsDataSource.data.count)
                    return CGSize(width: width, height: collectionSize.height)
                }
            }
        }
        let provider = BasicProvider (
            dataSource: self.btnsDataSource,
            viewSource: viewSource,
            sizeSource: sizeSource
        )
        provider.layout = RowLayout(spacing: 0)

        return provider
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.labsCollectionView.provider = self.labsProvider
        self.btnsCollectionView.provider = self.btnsProvider
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXActivitystaffsModel?, myRoleType: String?, isMeAdmin: Bool) {
        self.myRoleType = myRoleType
        guard let data = model else { return }

        self.avatarButton.kf.setImage(with: URL(string: data.avatarPic), for: .normal, placeholder: UIImage.defaultAvatar)
        self.nameLabel.text = data.nickName

        //角色类型 1-发布者 2-管理员 3-核销票 4-客服
        var labList: [String] = []
        var btnList: [String] = []

        if GXRoleUtil.isPublisher(roleType: data.roleType) {
            labList.append("发布者")
            if data.userId == GXUserManager.shared.user?.id && isMeAdmin {
                labList.append("管理员")
            }
            else if GXRoleUtil.isOneAdmin(roleType: data.roleType) {
                labList.append("管理员")
            }
        }
        else if GXRoleUtil.isOneAdmin(roleType: data.roleType) {
            labList.append("管理员")
        }
        else {
            if GXRoleUtil.isPublisher(roleType: myRoleType) {
                btnList.append("移交为管理员")
            }
            btnList.append("移除")
        }
        if GXRoleUtil.isTeller(roleType: data.roleType) {
            labList.append("核销票")
            btnList.insert("取消核销票", at: 0)
        }
        else {
            btnList.insert("增加核销票", at: 0)
        }
        if GXRoleUtil.isService(roleType: data.roleType) {
            labList.append("客服")
            btnList.insert("取消客服", at: 0)
        }
        else {
            btnList.insert("增加客服", at: 0)
        }
        self.labsDataSource.data = labList
        self.btnsDataSource.data = btnList
    }
}

extension GXPublishMemberWorkerCell {
    @IBAction func avatarButtonClicked(_ sender: UIButton) {
        self.avatarAction?(self)
    }
    @objc func buttonClicked(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        self.buttonAction?(self, title)
    }

}
