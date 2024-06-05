//
//  GXChatGroupMemberVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/24.
//

import UIKit
import MBProgressHUD

class GXChatGroupMemberVC: GXBaseViewController {
    @IBOutlet weak var memberNumLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    private var cellSize: CGSize = .init(width: 48, height: 60)
    private var column: Int = Int((SCREEN_WIDTH - 40) / 48)

    class func createVC(messageType: Int, chatId: Int, title: String?) -> GXChatGroupMemberVC {
        return GXChatGroupMemberVC.xibViewController().then {
            $0.viewModel.messageType = messageType
            $0.viewModel.activityId = chatId
            $0.title = title
        }
    }

    private lazy var viewModel: GXChatGroupMemberViewModel = {
        return GXChatGroupMemberViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestActivityUsers()
    }

    override func setupViewController() {
        self.gx_addBackBarButtonItem()
        self.collectionView.register(cellType: GXChatGroupMemberCell.self)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func updateTopMemberCount() {
        self.memberNumLabel.text = "成员 \(viewModel.userList.count)人"
    }
}

extension GXChatGroupMemberVC {
    func requestActivityUsers() {
        guard (self.viewModel.messageType == 3 || self.viewModel.messageType == 4) else { return }
        MBProgressHUD.showLoading(ballColor: .white, to: self.view)
        self.viewModel.requestActivityUsers(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.updateTopMemberCount()
            self?.collectionView.reloadData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXChatGroupMemberVC: UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let allSpacing = (collectionView.width - 40) - self.cellSize.width * CGFloat(self.column)
        let spacing = allSpacing / CGFloat(self.column - 1)
        return floor(spacing)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }

    // MARK: - UICollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.viewModel.userList[indexPath.item]
        let vc = GXMinePtOtherVC(userId: String(model.userId))
        let nav = GXBaseNavigationController(rootViewController: vc)
        self.gx_present(nav, style: .push)
    }
}

extension GXChatGroupMemberVC: UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.userList.count 
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GXChatGroupMemberCell = collectionView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.userList[indexPath.item]
        cell.bindCell(model: model)
        return cell
    }
}


