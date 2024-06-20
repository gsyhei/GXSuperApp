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
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 20
            $0.addTarget(self, action: #selector(confirmButtonClicked(_:)), for: .touchUpInside)
        }
    }()
    
    private var titleList: [String] = ["Sort", "Station Service", "Station Location", "Parking Discount", "My Preferences"]
    private var titleCellList: [String] = ["Restroom", "Store", "Restauraut", "Lounge", "Favorite Stations"]

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
        
    }
    
    @objc func confirmButtonClicked(_ sender: Any?) {
        
    }
}

extension GXHomeFilterMenu: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.titleList.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titleCellList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header: GXHomeFilterHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
            header.titleLabel.text = self.titleList[indexPath.item]
            return header
        }
        else {
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GXHomeFilterCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.nameLabel.text = self.titleCellList[indexPath.item]
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = self.titleCellList[indexPath.item]
        let width = title.width(font: .gx_font(size: 14)) + 20
        return CGSize(width: width, height: 32)
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
        
    }
}
