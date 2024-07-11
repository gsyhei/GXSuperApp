//
//  GXHomeSearchHistoryCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/18.
//

import UIKit
import Reusable
import CollectionKit

class GXHomeSearchHistoryCell: UITableViewCell, Reusable {
    private var font = UIFont.gx_font(size: 15)
    var dataSource = ArrayDataSource<GXPlace>()
    var action: GXActionBlockItem<GXPlace>?

    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: GXPlace, index: Int) in
            view.titleLabel?.font = self.font
            view.setTitle(data.address, for: .normal)
            view.setTitleColor(.gx_drakGray, for: .normal)
            view.setTitleColor(.white, for: .highlighted)
            view.setBackgroundColor(.gx_background, for: .normal)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 16.0
            view.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
            view.tag = index
        })
        let sizeSource = { (index: Int, data: GXPlace, collectionSize: CGSize) -> CGSize in
            let dataWidth = data.address.width(font: self.font) + 20
            let width = min(dataWidth, collectionSize.width)
            return CGSize(width: width, height: 32)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource
        )
        provider.layout = FlowLayout(spacing: 10.0)
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
        self.selectionStyle = .none
        self.contentView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
    
    func updateDataSource() {
        self.dataSource.data = GXPlacesManager.shared.places
    }
    
}

extension GXHomeSearchHistoryCell {
    @objc func buttonClicked(_ sender: UIButton) {
        let index = sender.tag
        self.action?(self.dataSource.data[index])
    }
}
