//
//  GXHomeDetailCell0.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/22.
//

import UIKit
import CollectionKit
import Reusable

class GXHomeDetailCell0: UITableViewCell, Reusable {
    
    private var dataSource = ArrayDataSource<String>()
    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIImageView, data: String, index: Int) in
            view.kf.setImage(with: URL(string: data), placeholder: UIImage.gx_default)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 8.0
        })
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 160, height: collectionSize.height)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: {[weak self] tapContext in
                guard let `self` = self else { return }

            }
        )
        provider.layout = RowLayout(spacing: 6.0)
        return CollectionView(provider: provider)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSubviews() {
        self.contentView.backgroundColor = .gx_background
        self.isSkeletonable = true
        self.collectionView.isSkeletonable = true
        self.dataSource.data = ["", ""]
        self.collectionView.showsHorizontalScrollIndicator = false
        self.contentView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(100)
            make.bottom.equalToSuperview()
        }
        self.collectionView.layoutIfNeeded()
    }
    
    func bindCell(model: GXStationConsumerDetailData?) {
        guard let model = model else { return }
        self.dataSource.data = model.aroundServicesArr
    }

}
