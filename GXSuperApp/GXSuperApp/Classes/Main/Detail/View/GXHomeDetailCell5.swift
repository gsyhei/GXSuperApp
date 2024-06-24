//
//  GXHomeDetailCell5.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit
import Reusable
import SkeletonView

class GXHomeDetailCell5: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(estimated: true)
            tableView.sectionHeaderHeight = 0
            tableView.sectionFooterHeight = 0
            tableView.rowHeight = 64
            tableView.separatorColor = .gx_lightGray
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(cellType: GXHomeDetailChargerStatusCell.self)
        }
    }
    var moreAction: GXActionBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.moreButton.imageLocationAdjust(model: .right, spacing: 8)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension GXHomeDetailCell5: SkeletonTableViewDataSource, SkeletonTableViewDelegate {

    // MARK: - SkeletonTableViewDataSource
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return GXHomeDetailChargerStatusCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        let cell: GXHomeDetailChargerStatusCell = skeletonView.dequeueReusableCell(for: indexPath)
        return cell
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, prepareCellForSkeleton cell: UITableViewCell, at indexPath: IndexPath) {
        
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXHomeDetailChargerStatusCell = tableView.dequeueReusableCell(for: indexPath)
        return cell
    }
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

private extension GXHomeDetailCell5 {
    @IBAction func moreButtonClicked(_ sender: Any?) {
        self.moreAction?()
    }
}
