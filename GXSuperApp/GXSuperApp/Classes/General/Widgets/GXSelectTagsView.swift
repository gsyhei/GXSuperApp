//
//  GXSelectTagsView.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/11.
//

import UIKit
import CollectionKit

class GXSelectTagsView: UIView {
    private var font = UIFont.gx_font(size: 13)
    var dataSource = ArrayDataSource<String>()
    
    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: String, index: Int) in
            view.titleLabel?.font = self.font
            view.setTitle(data, for: .normal)
            view.setTitleColor(.gx_drakGray, for: .normal)
            view.setTitleColor(.white, for: .selected)
            view.setBackgroundColor(.white, for: .normal)
            view.setBackgroundColor(.gx_green, for: .selected)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 12.0
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor.gx_gray.cgColor
            view.isUserInteractionEnabled = false
        })
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
            let width = data.width(font: self.font) + 20
            return CGSize(width: width, height: 24)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: {[weak self] tapContext in
                guard let `self` = self else { return }
                tapContext.view.isSelected = !tapContext.view.isSelected
            }
        )
        provider.layout = RowLayout(spacing: 6.0)
        return CollectionView(provider: provider)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.dataSource.data = ["Super charge", "Fast charge", "Slow charge", "Parking charge", "Last charge"]
    }
    
}
