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
    var dataSource = ArrayDataSource<GXDictListAvailableData>()
    private lazy var stationServiceList: [Int] = {
        return GXUserManager.shared.filter.getSelectedAroundFacilities()
    }()
    var itemAction: GXActionBlock?
    
    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: GXDictListAvailableData, index: Int) in
            view.titleLabel?.font = self.font
            view.setTitle(data.name, for: .normal)
            view.setTitleColor(.gx_drakGray, for: .normal)
            view.setTitleColor(.white, for: .selected)
            view.setBackgroundColor(.white, for: .normal)
            view.setBackgroundColor(.gx_green, for: .selected)
            view.isSelected = self.stationServiceList.contains(data.id)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 12.0
            view.isUserInteractionEnabled = false
        })
        let sizeSource = { (index: Int, data: GXDictListAvailableData, collectionSize: CGSize) -> CGSize in
            let width = data.name.width(font: self.font) + 20
            return CGSize(width: width, height: 24)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: {[weak self] tapContext in
                guard let `self` = self else { return }
                tapContext.view.isSelected = !tapContext.view.isSelected
                
                var selectedList = GXUserManager.shared.filter.getSelectedAroundFacilities()
                if tapContext.view.isSelected {
                    selectedList.append(tapContext.data.id)
                } else {
                    selectedList.removeAll(where: { return $0 == tapContext.data.id })
                }
                GXUserManager.shared.filter.setSelectedAroundFacilities(list: selectedList)
                self.itemAction?()
            }
        )
        provider.layout = RowLayout(spacing: 6.0)
        return CollectionView(provider: provider)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        self.collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updateSelectedTags() {
        self.stationServiceList = GXUserManager.shared.filter.getSelectedAroundFacilities()
        self.collectionView.reloadData()
    }
    
    func updateDataSource() {
        self.dataSource.data = GXUserManager.shared.showAvailableList
    }
}
