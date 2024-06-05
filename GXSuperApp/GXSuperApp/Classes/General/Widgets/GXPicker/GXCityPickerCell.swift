//
//  GXCityPickerCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/26.
//

import UIKit
import Reusable
import CollectionKit

class GXCityPickerCell: UITableViewCell, Reusable {
    var dataSource = ArrayDataSource<GXCityItem>()
    var selectedAction: GXActionBlockItem<GXCityItem>?
    var selectedCity: String = ""

    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: GXCityItem, index: Int) in
            view.titleLabel?.font = .gx_font(size: 15)
            view.setTitle(data.cityName, for: .normal)
            view.setTitleColor(.gx_black, for: .normal)
            view.setBackgroundColor(.white, for: .normal)
            view.setBackgroundColor(.gx_green, for: .selected)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 4.0
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor.gx_lightGray.cgColor
            view.isUserInteractionEnabled = false
            view.isSelected = self.selectedCity.contains(find: data.cityName)
        })
        let sizeSource = { (index: Int, data: GXCityItem, collectionSize: CGSize) -> CGSize in
            let width: Int = Int(collectionSize.width - 48.0) / 3
            return CGSize(width: width, height: 32)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: {[weak self] tapContext in
                guard let `self` = self else { return }
                for cell in self.collectionView.visibleCells {
                    if let button = cell as? UIButton {
                        button.isSelected = (button == tapContext.view)
                    }
                }
                self.selectedAction?(tapContext.data)
            }
        )
        provider.layout = FlowLayout(spacing: 8.0)
        return CollectionView(provider: provider)
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.reloadData()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindCell(list: [GXCityItem], selectedCity: String) {
        self.selectedCity = selectedCity
        self.dataSource.data = list
    }
}
