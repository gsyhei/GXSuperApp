//
//  GXCollectionTagsView.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/3/16.
//

import UIKit
import CollectionKit


class GXCollectionTagsItem: NSObject {
    var title: String
    var color: UIColor

    init(title: String, color: UIColor) {
        self.title = title
        self.color = color
    }
}

class GXCollectionTagsView: UIView {
    private let rowHeight = 16.0
    private let font = UIFont.gx_font(size: 10)
    private var dataSource = ArrayDataSource<GXCollectionTagsItem>()
    
    private(set) lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UILabel, data: GXCollectionTagsItem, index: Int) in
            view.textAlignment = .center
            view.font = self.font
            view.text = data.title
            view.textColor = data.color
            view.layer.masksToBounds = true
            view.layer.borderWidth = 1.0
            view.layer.borderColor = data.color.cgColor
            view.layer.cornerRadius = self.rowHeight/2
        })
        let sizeSource = { (index: Int, data: GXCollectionTagsItem, collectionSize: CGSize) -> CGSize in
            let width = data.title.width(font: self.font) + 10
            return CGSize(width: width, height: self.rowHeight)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource
        )
        provider.layout = FlowLayout(spacing: 4.0)
        return CollectionView(provider: provider)
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.reloadData()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.collectionView.isScrollEnabled = false
    }

    func updateTags(isVip: Bool = false,
                    isSm: Bool = false,
                    isJg: Bool = false,
                    isGf: Bool = false,
                    isDr: Bool = false,
                    userExpertTitles: [String] = []) {
        var tagItems: [GXCollectionTagsItem] = []
        if isVip {
            tagItems.append(GXCollectionTagsItem(title: "VIP", color: .gx_yellow))
        }
        if isSm {
            tagItems.append(GXCollectionTagsItem(title: "实名", color: .gx_yellow))
        }
        if isJg {
            tagItems.append(GXCollectionTagsItem(title: "机构认证", color: .gx_blue))
        }
        if isGf {
            tagItems.append(GXCollectionTagsItem(title: "官方认证", color: .gx_blue))
        }
        if isDr {
            tagItems.append(GXCollectionTagsItem(title: "达人", color: .gx_purple))
        }
        for title in userExpertTitles {
            tagItems.append(GXCollectionTagsItem(title: title, color: .gx_purple))
        }
        self.dataSource.data = tagItems
    }
}
