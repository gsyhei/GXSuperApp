//
//  GXHomeDetailChargerStatusMenu.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit

class GXHomeDetailChargerStatusMenu: GXBaseMenuView {
    private weak var viewModel: GXHomeDetailViewModel?
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        return UICollectionView(frame: self.bounds, collectionViewLayout: layout).then {
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXHomeDetailChargerCell.self)
        }
    }()

    override func createSubviews() {
        super.createSubviews()
        
        self.titleLabel.text = "Charger Status"
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.topLineView.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-15)
        }
    }
    
    func bindView(viewModel: GXHomeDetailViewModel?) {
        guard let viewModel = viewModel else { return }
        self.viewModel = viewModel
        self.collectionView.reloadData()
        
        let cloumn = (viewModel.ccRowsList.count + 1) / 2
        var height = CGFloat(94 * cloumn) + CGFloat((cloumn - 1) * 12)
        height += self.safeAreaHeight + 30
        self.updateHeight(height: height)
    }
}

extension GXHomeDetailChargerStatusMenu: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.ccRowsList.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GXHomeDetailChargerCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.bindCell(model: self.viewModel?.ccRowsList[indexPath.row])
        return cell
    }
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.width - 12)/2, height: 94)
    }
}
