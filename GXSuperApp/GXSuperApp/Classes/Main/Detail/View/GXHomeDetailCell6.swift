//
//  GXHomeDetailCell6.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit
import Reusable
import CollectionKit
import Kingfisher

class GXHomeDetailCell6: UITableViewCell, NibReusable {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cvHeightLC: NSLayoutConstraint!
    var dataSource = ArrayDataSource<GXStationConsumerDetailTagslistItem>()

    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: GXHomeDetailFacilitiesView, data: GXStationConsumerDetailTagslistItem, index: Int) in
            view.nameLabel.text = data.name
            view.iconIView.kf.setImage(with: URL(string: data.icon), placeholder: UIImage.gx_default)
            view.nameLabel.textColor = .gx_drakGray
            view.contentMode = .scaleAspectFit
            view.masksToBounds = true
        })
        let sizeSource = { (index: Int, data: GXStationConsumerDetailTagslistItem, collectionSize: CGSize) -> CGSize in
            let width = collectionSize.width / 5
            return CGSize(width: width, height: 44)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource
        )
        provider.layout = FlowLayout(lineSpacing: 10, interitemSpacing: 0)
        return CollectionView(provider: provider)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.createSubviews()
    }
    
    private func createSubviews() {
        self.contentView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-18)
            make.height.equalTo(44)
        }
    }
    
    func bindCell(list: [GXStationConsumerDetailTagslistItem]?) {
        guard let list = list else { return }
        self.dataSource.data = list
        self.collectionView.reloadData()
        self.layoutIfNeeded()
        self.cvHeightLC.constant = self.collectionView.contentSize.height + 70
    }
}
