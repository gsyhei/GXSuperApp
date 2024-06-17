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
    private var font = UIFont.gx_font(size: 14)
    var dataSource = ArrayDataSource<String>()
    
    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: String, index: Int) in
            view.titleLabel?.font = self.font
            view.setTitle(data, for: .normal)
            view.setTitleColor(.gx_drakGray, for: .normal)
            view.setTitleColor(.white, for: .selected)
            view.setBackgroundColor(.gx_background, for: .normal)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 16.0
            view.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        })
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
            let width = data.width(font: self.font) + 20
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
        self.dataSource.data = ["Starbucks", "Starbucks", "Starbucks", "Starbucks", "Starbucks", "Starbucks", "Starbucks", "Starbucks", "Starbucks"]
    }
    
}

extension GXHomeSearchHistoryCell {
    @objc func buttonClicked(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        
    }
}
