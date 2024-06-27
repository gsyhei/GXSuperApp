//
//  GXHomeDetailCell3.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/23.
//

import UIKit
import Reusable
import SkeletonView

class GXHomeDetailCell3: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var costButton: UIButton!
    @IBOutlet weak var safetyButton: UIButton!
    @IBOutlet weak var allTimeButton: UIButton!
    @IBOutlet weak var tvHeightLC: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(estimated: true)
            tableView.sectionHeaderHeight = 22
            tableView.sectionFooterHeight = 0
            tableView.rowHeight = 44
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(headerFooterViewType: GXHomeDetailChargingFeeHeader.self)
            tableView.register(cellType: GXHomeDetailChargingFeeCell.self)
        }
    }
    private var showPrices:[GXStationConsumerDetailPricesItem] = []

    var costAction: GXActionBlock?
    var safetyAction: GXActionBlock?
    var allTimeAction: GXActionBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.costButton.imageLocationAdjust(model: .right, spacing: 4)
        self.safetyButton.imageLocationAdjust(model: .right, spacing: 4)
        self.allTimeButton.imageLocationAdjust(model: .right, spacing: 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(showPrices:[GXStationConsumerDetailPricesItem]?) {
        guard let showPrices = showPrices else { return }
        
        self.showPrices = showPrices
        let height = tableView.rowHeight * CGFloat(showPrices.count) + tableView.sectionHeaderHeight
        self.tvHeightLC.constant = height
        self.tableView.reloadData()
    }
}

extension GXHomeDetailCell3: SkeletonTableViewDataSource, SkeletonTableViewDelegate {

    // MARK: - SkeletonTableViewDataSource
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return GXHomeDetailChargingFeeCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        let cell: GXHomeDetailChargingFeeCell = skeletonView.dequeueReusableCell(for: indexPath)
        return cell
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, prepareCellForSkeleton cell: UITableViewCell, at indexPath: IndexPath) {
        
    }
    
    // MARK: - SkeletonTableViewDelegate
    
    func collectionSkeletonView(_ skeletonView: UITableView, identifierForHeaderInSection section: Int) -> ReusableHeaderFooterIdentifier? {
        return GXHomeDetailChargingFeeHeader.reuseIdentifier
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showPrices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXHomeDetailChargingFeeCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bindCell(model: self.showPrices[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(GXHomeDetailChargingFeeHeader.self)
        return header
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

private extension GXHomeDetailCell3 {
    
    @IBAction func costButtonClicked(_ sender: Any?) {
        self.costAction?()
    }
    
    @IBAction func safetyButtonClicked(_ sender: Any?) {
        self.safetyAction?()
    }
    
    @IBAction func allTimeButtonClicked(_ sender: Any?) {
        self.allTimeAction?()
    }
    
}
