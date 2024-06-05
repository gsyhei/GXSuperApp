//
//  GXPrHomeSearchHistoryCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/28.
//

import UIKit
import Reusable
import CollectionKit

class GXPrHomeSearchHistoryCell: UITableViewCell, Reusable {
    var selectedAction: GXActionBlockItem<String>?
    var dataSource = ArrayDataSource<String>()

    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: String, index: Int) in
            view.titleLabel?.font = .gx_font(size: 14)
            view.setTitle(data, for: .normal)
            view.setTitleColor(.gx_black, for: .normal)
            view.setBackgroundColor(.gx_background, for: .normal)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 13.0
            view.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        })
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
            let width = data.width(font: .gx_font(size: 14)) + 32.0
            return CGSize(width: width, height: 26)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource
        )
        provider.layout = FlowLayout(spacing: 8.0)
        return CollectionView(provider: provider)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        self.selectionStyle = .none
        self.contentView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(42)
        }
    }

    func bindCell(list: [String]) {
        self.dataSource.data = list
        self.contentView.layoutIfNeeded()
        let size = self.dataSource.collectionView?.contentSize ?? .zero
        self.collectionView.snp.updateConstraints { make in
            make.height.equalTo(size.height + 17)
        }
    }

    @objc func buttonClicked(_ sender: UIButton) {
        let index = self.collectionView.index(for: sender) ?? 0
        let data = self.dataSource.data[index]
        self.selectedAction?(data)
    }

}
