//
//  GXChatGroupMemberHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/24.
//

import UIKit

class GXChatGroupMemberHeader: UIView {
    @IBOutlet weak var memberNumLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var groupLabel: UILabel!
    private var cellSize: CGSize = .init(width: 48, height: 60)
    private var column: Int = Int((SCREEN_WIDTH - 40) / 48)
    private var isMore: Bool {
        return (self.viewModel?.userList.count ?? 0) > self.column
    }
    weak var viewModel: GXChatViewModel?
    var userAction: GXActionBlockItem<GXActivityUser?>?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.groupLabel.font = .gx_dingTalkFont(size: 20)

        self.collectionView.register(cellType: GXChatGroupMemberCell.self)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    func bindHeaderView(viewModel: GXChatViewModel) {
        self.viewModel = viewModel
        self.memberNumLabel.text = "成员 \(viewModel.userList.count)人"
        self.collectionView.reloadData()
    }
}

extension GXChatGroupMemberHeader: UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let allSpacing = (collectionView.width - 40) - self.cellSize.width * CGFloat(self.column)
        let spacing = allSpacing / CGFloat(self.column - 1)
        return floor(spacing)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }

    // MARK: - UICollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isMore && indexPath.item == self.column - 1 {
            self.userAction?(nil)
        }
        else {
            let model = self.viewModel?.userList[indexPath.item]
            self.userAction?(model)
        }
    }
}

extension GXChatGroupMemberHeader: UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isMore {
            return self.column
        }
        return self.viewModel?.userList.count ?? 0
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GXChatGroupMemberCell = collectionView.dequeueReusableCell(for: indexPath)
        if self.isMore && indexPath.item == self.column - 1 {
            cell.bindCell(model: nil)
        }
        else {
            let model = self.viewModel?.userList[indexPath.item]
            cell.bindCell(model: model)
        }
        return cell
    }
}


