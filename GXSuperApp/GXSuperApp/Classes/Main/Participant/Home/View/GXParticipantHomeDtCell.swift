//
//  GXParticipantHomeDtCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/6.
//

import UIKit
import Reusable
import GXBanner

class GXParticipantHomeDtCell: UITableViewCell, NibReusable {
    @IBOutlet weak var collectionView: UICollectionView!
    var musiclist: [GXPtHomeGetMusicStationsItem] = []

    override func layoutSubviews() {
        super.layoutSubviews()
        self.separatorInset = UIEdgeInsets(top: 0, left: self.bounds.width/2, bottom: 0, right: self.bounds.width/2)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(cellType: GXParticipantHomeDtConCell.self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(list: [GXPtHomeGetMusicStationsItem]) {
        self.musiclist = list
        self.collectionView.reloadData()
    }
}

extension GXParticipantHomeDtCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.musiclist.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GXParticipantHomeDtConCell = collectionView.dequeueReusableCell(for: indexPath)
        let model = self.musiclist[indexPath.item]
        cell.bindCell(model: model)

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280.0, height: collectionView.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12.0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
