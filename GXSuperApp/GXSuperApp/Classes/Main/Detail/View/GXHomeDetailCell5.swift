//
//  GXHomeDetailCell5.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit
import Reusable
import SkeletonView

class GXHomeDetailCell5: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(cellType: GXHomeDetailChargerCell.self)
        }
    }
    
    var showItems: [GXConnectorConsumerRowsItem] = []
    var moreAction: GXActionBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.moreButton.imageLocationAdjust(model: .right, spacing: 8)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(items: [GXConnectorConsumerRowsItem]?) {
        guard let items = items, items.count > 0 else { return }
        self.showItems = items
        self.collectionView.reloadData()
    }
}

extension GXHomeDetailCell5: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.showItems.count > 2 ? 2 : self.showItems.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GXHomeDetailChargerCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.bindCell(model: self.showItems[indexPath.item])
        return cell
    }
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.width - 8)/2, height: 94)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

private extension GXHomeDetailCell5 {
    @IBAction func moreButtonClicked(_ sender: Any?) {
        self.moreAction?()
    }
}
