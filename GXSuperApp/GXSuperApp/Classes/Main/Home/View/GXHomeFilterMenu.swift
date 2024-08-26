//
//  GXHomeFilterMenu.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/20.
//

import UIKit

class GXHomeFilterMenu: GXBaseMenuView {
    
    private lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: self.bounds, collectionViewLayout: GXCollectionViewAlignmentLeftLayout()).then {
            $0.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            $0.backgroundColor = .white
            $0.dataSource = self
            $0.delegate = self
            $0.allowsMultipleSelection = true
            $0.register(supplementaryViewType: GXHomeFilterHeader.self, ofKind: UICollectionView.elementKindSectionHeader)
            $0.register(cellType: GXHomeFilterCell.self)
        }
    }()
    
    private lazy var resetButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.titleLabel?.font = .gx_font(size: 16)
            $0.setTitle("Reset", for: .normal)
            $0.setTitleColor(.gx_green, for: .normal)
            $0.setBackgroundColor(.white, for: .normal)
            $0.setBackgroundColor(.gx_background, for: .highlighted)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 20
            $0.layer.borderWidth = 1.0
            $0.layer.borderColor = UIColor.gx_green.cgColor
            $0.addTarget(self, action: #selector(resetButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    private lazy var confirmButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.titleLabel?.font = .gx_font(size: 16)
            $0.setTitle("Confirm", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.setBackgroundColor(.gx_green, for: .normal)
            $0.setBackgroundColor(.gx_drakGreen, for: .highlighted)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 20
            $0.addTarget(self, action: #selector(confirmButtonClicked(_:)), for: .touchUpInside)
        }
    }()
    
    private var titleList: [String] = ["Sort", "Plugs", "Station Service", "Station Location", "My Preferences"]
    private var titleCellList: [Int: [String]] = [
        0 : ["Nearest", "Lowest Price"],
        1 : ["Tesla", "US"],
        2 : ["Restroom", "Store", "Restauraut", "Lounge", "Gym"],
        3 : ["Ground", "Parking Lot"],
        4 : ["Favorite Stations"],
    ]
    
    private lazy var selectedModel: GXHomeFilterModel = {
        return GXUserManager.shared.filter.gx_copy()
    }()
    private lazy var stationServiceList: [Int] = {
        return self.selectedModel.getSelectedAroundFacilities()
    }()
    var confirmAction: GXActionBlock?

    override func createSubviews() {
        super.createSubviews()
        
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.topLineView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-60)
        }
        self.addSubview(self.resetButton)
        self.resetButton.snp.makeConstraints { make in
            make.top.equalTo(self.collectionView.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(40)
        }
        self.addSubview(self.confirmButton)
        self.confirmButton.snp.makeConstraints { make in
            make.top.equalTo(self.collectionView.snp.bottom).offset(5)
            make.left.equalTo(self.resetButton.snp.right).offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
            make.width.equalTo(self.resetButton.snp.width)
        }
    }
    
    @objc func resetButtonClicked(_ sender: Any?) {
        self.selectedModel.orderType = nil
        self.stationServiceList.removeAll()
        self.selectedModel.setSelectedPosition(index: nil)
        self.selectedModel.teslaFlag = nil
        self.selectedModel.favorite = nil
        self.collectionView.reloadData()
    }
    
    @objc func confirmButtonClicked(_ sender: Any?) {
        GXUserManager.shared.filter.orderType = self.selectedModel.orderType
        GXUserManager.shared.filter.setSelectedAroundFacilities(list: self.stationServiceList)
        GXUserManager.shared.filter.position = self.selectedModel.position
        GXUserManager.shared.filter.teslaFlag = self.selectedModel.teslaFlag
        GXUserManager.shared.filter.favorite = self.selectedModel.favorite
        
        self.hide(animated: true)
        self.confirmAction?()
    }
}

extension GXHomeFilterMenu: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.titleList.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 2 {
            return GXUserManager.shared.availableList.count
        }
        if let nameList = self.titleCellList[section] {
            return nameList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header: GXHomeFilterHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
            header.titleLabel.text = self.titleList[indexPath.section]
            return header
        }
        else {
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GXHomeFilterCell = collectionView.dequeueReusableCell(for: indexPath)
        if indexPath.section == 2 {
            let item = GXUserManager.shared.availableList[indexPath.item]
            cell.nameLabel.text = item.name
            cell.isChecked = self.stationServiceList.contains(item.id)
        }
        else if let nameList = self.titleCellList[indexPath.section] {
            cell.nameLabel.text = nameList[indexPath.item]
        }
        switch indexPath.section {
        case 0:
            cell.isChecked = (self.selectedModel.orderType == indexPath.item + 1)
        case 1:
            cell.isChecked = (self.selectedModel.getSelectedTeslaFlagIndex() == indexPath.item)
        case 3:
            cell.isChecked = (self.selectedModel.getSelectedPositionIndex() == indexPath.item)
        case 4:
            cell.isChecked = (self.selectedModel.favorite == true)
        default: break
        }
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 2 {
            let item = GXUserManager.shared.availableList[indexPath.item]
            let width = item.name.width(font: .gx_font(size: 15)) + 20
            return CGSize(width: max(width, 60), height: 32)
        }
        if let nameList = self.titleCellList[indexPath.section] {
            let title = nameList[indexPath.item]
            let width = title.width(font: .gx_font(size: 15)) + 20
            return CGSize(width: max(width, 60), height: 32)
        }
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if self.selectedModel.orderType == indexPath.row + 1 {
                self.selectedModel.orderType = nil
            }
            else {
                self.selectedModel.orderType = indexPath.row + 1
            }
        case 1:
            if self.selectedModel.getSelectedTeslaFlagIndex() == indexPath.item {
                self.selectedModel.setSelectedTeslaFlag(index: nil)
            }
            else {
                self.selectedModel.setSelectedTeslaFlag(index: indexPath.item)
            }
        case 2:
            let item = GXUserManager.shared.availableList[indexPath.item]
            if self.stationServiceList.contains(item.id) {
                self.stationServiceList.removeAll(where: { return $0 == item.id })
            } else {
                self.stationServiceList.append(item.id)
            }
        case 3:
            if self.selectedModel.getSelectedPositionIndex() == indexPath.item {
                self.selectedModel.setSelectedPosition(index: nil)
            }
            else {
                self.selectedModel.setSelectedPosition(index: indexPath.item)
            }
        case 4:
            self.selectedModel.favorite = (self.selectedModel.favorite == nil) ? true : nil
        default: break
        }
        UIView.performWithoutAnimation {
            self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
        }
    }
}
