//
//  GXHomeDetailCell6.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit
import Reusable
import CollectionKit

class GXHomeDetailCell6: UITableViewCell, NibReusable {
    @IBOutlet weak var nameLabel: UILabel!
    var dataSource = ArrayDataSource<String>()
    var action: GXActionBlockItem<String>?

    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: GXHomeDetailFacilitiesView, data: String, index: Int) in
            view.nameLabel.text = data
            view.iconIView.image = UIImage(named: "details_list_ic_store_normal")
        })
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
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
        self.dataSource.data = ["Restroom", "Store", "Restauraut", "Lounge", "Gym"]
    }
    
}
