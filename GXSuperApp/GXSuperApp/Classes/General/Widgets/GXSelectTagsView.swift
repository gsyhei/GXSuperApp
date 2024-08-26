//
//  GXSelectTagsView.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/11.
//

import UIKit
import CollectionKit

class GXSelectTagModel: NSObject {
    var title: String = ""
    var id: Int?
    var isSelected: Bool
    var action: GXActionBlockItem<GXSelectTagModel>?
    
    init(title: String, id: Int? = nil, isSelected: Bool = false, action: GXActionBlockItem<GXSelectTagModel>? = nil) {
        self.title = title
        self.id = id
        self.isSelected = isSelected
        self.action = action
    }
}

class GXSelectTagsView: UIView {
    private var font = UIFont.gx_font(size: 13)
    var dataSource = ArrayDataSource<GXSelectTagModel>()
    var itemAction: GXActionBlock?
    
    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: GXSelectTagModel, index: Int) in
            view.titleLabel?.font = self.font
            view.setTitle(data.title, for: .normal)
            view.setTitleColor(.gx_drakGray, for: .normal)
            view.setTitleColor(.white, for: .selected)
            view.setBackgroundColor(.white, for: .normal)
            view.setBackgroundColor(.gx_green, for: .selected)
            view.isSelected = data.isSelected
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 12.0
            view.isUserInteractionEnabled = false
        })
        let sizeSource = { (index: Int, data: GXSelectTagModel, collectionSize: CGSize) -> CGSize in
            let width = data.title.width(font: self.font) + 20
            return CGSize(width: width, height: 24)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: {[weak self] tapContext in
                guard let `self` = self else { return }
                tapContext.data.action?(tapContext.data)
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
    
    func updateDataSource() {
        var list: [GXSelectTagModel] = []
        list.append(GXSelectTagModel(title: "Nearest", action: {[weak self] model in
            if GXUserManager.shared.filter.orderType == 1 {
                GXUserManager.shared.filter.orderType = nil
            }
            else {
                GXUserManager.shared.filter.orderType = 1
            }
            self?.updateSelectedTags()
        }))
        list.append(GXSelectTagModel(title: "Lowest Price", action: {[weak self] model in
            if GXUserManager.shared.filter.orderType == 2 {
                GXUserManager.shared.filter.orderType = nil
            }
            else {
                GXUserManager.shared.filter.orderType = 2
            }
            self?.updateSelectedTags()
        }))
        list.append(GXSelectTagModel(title: "Tesla", action: {[weak self] model in
            if GXUserManager.shared.filter.teslaFlag == GXBOOL.YES.rawValue {
                GXUserManager.shared.filter.teslaFlag = nil
            }
            else {
                GXUserManager.shared.filter.teslaFlag = GXBOOL.YES.rawValue
            }
            self?.updateSelectedTags()
        }))
        list.append(GXSelectTagModel(title: "US", action: {[weak self] model in
            if GXUserManager.shared.filter.teslaFlag == GXBOOL.NO.rawValue {
                GXUserManager.shared.filter.teslaFlag = nil
            }
            else {
                GXUserManager.shared.filter.teslaFlag = GXBOOL.NO.rawValue
            }
            self?.updateSelectedTags()
        }))
        
        for showAvailable in GXUserManager.shared.showAvailableList {
            list.append(GXSelectTagModel(title: showAvailable.name, id: showAvailable.id, action: {[weak self] model in
                var selectedList = GXUserManager.shared.filter.getSelectedAroundFacilities()
                if model.isSelected {
                    selectedList.removeAll(where: { return $0 == model.id })
                } else {
                    selectedList.append(model.id ?? 0)
                }
                GXUserManager.shared.filter.setSelectedAroundFacilities(list: selectedList)
                self?.updateSelectedTags()
            }))
        }
        
        list.append(GXSelectTagModel(title: "Ground", action: {[weak self] model in
            if GXUserManager.shared.filter.position == "LAND" {
                GXUserManager.shared.filter.position = nil
            }
            else {
                GXUserManager.shared.filter.position = "LAND"
            }
            self?.updateSelectedTags()
        }))
        list.append(GXSelectTagModel(title: "Parking Lot", action: {[weak self] model in
            if GXUserManager.shared.filter.position == "UNDERGROUND" {
                GXUserManager.shared.filter.position = nil
            }
            else {
                GXUserManager.shared.filter.position = "UNDERGROUND"
            }
            self?.updateSelectedTags()
        }))
        list.append(GXSelectTagModel(title: "Favorite Stations", action: {[weak self] model in
            if GXUserManager.shared.filter.favorite == true {
                GXUserManager.shared.filter.favorite = nil
            }
            else {
                GXUserManager.shared.filter.favorite = true
            }
            self?.updateSelectedTags()
        }))
        
        self.dataSource.data = list
        self.updateSelectedTags()
    }
    
    func updateSelectedTags() {
        let selectedList = GXUserManager.shared.filter.getSelectedAroundFacilities()
        for model in self.dataSource.data {
            if let tagId = model.id {
                model.isSelected = selectedList.contains(tagId)
            }
            else {
                switch model.title {
                case "Nearest":
                    model.isSelected = (GXUserManager.shared.filter.orderType == 1)
                case "Lowest Price":
                    model.isSelected = (GXUserManager.shared.filter.orderType == 2)
                case "Tesla":
                    model.isSelected = (GXUserManager.shared.filter.teslaFlag == GXBOOL.YES.rawValue)
                case "US":
                    model.isSelected = (GXUserManager.shared.filter.teslaFlag == GXBOOL.NO.rawValue)
                case "Ground":
                    model.isSelected = (GXUserManager.shared.filter.position == "LAND")
                case "Parking Lot":
                    model.isSelected = (GXUserManager.shared.filter.position == "UNDERGROUND")
                case "Favorite Stations":
                    model.isSelected = (GXUserManager.shared.filter.favorite == true)
                default: break
                }
            }
        }
        self.collectionView.reloadData()
    }
}
