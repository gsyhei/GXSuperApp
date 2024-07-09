//
//  GXChargingOrderDetailsCell3.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/8.
//

import UIKit
import Reusable
import SkeletonView

class GXChargingOrderDetailsCell3: UITableViewCell, NibReusable {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tableHeightLC: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration()
            tableView.dataSource = self
            tableView.estimatedRowHeight = 34
            tableView.rowHeight = UITableView.automaticDimension
            tableView.register(cellType: GXChargingOrderLRTextCell.self)
        }
    }
    private var tableList: [GXChargingOrderLRTextCell.Model] = [] {
        didSet {
            self.tableHeightLC.constant = tableView.estimatedRowHeight * CGFloat(tableList.count)
            self.tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXChargingOrderDetailData?) {
        guard let model = model else { return }
        
        self.feeLabel.text = "$\(model.occupyFee)"
        
        //豁免类型；VAL0：未豁免，VAL1：豁免+结算前，VAL2：豁免退款+结算前，VAL3：豁免+结算后，VAL4：豁免退款+结算后
        switch model.exemptType {
        case "VAL1", "VAL3", "VAL2", "VAL4":
            self.tagView.isHidden = false
            self.tagLabel.text = "Waived"
        default:
            self.tagView.isHidden = true
        }
        
        var list: [GXChargingOrderLRTextCell.Model] = []
        if !model.occupyFreePeriod.isEmpty {
            let cellModel0 = GXChargingOrderLRTextCell.Model(leftText: model.occupyFreePeriod, rightText: "Free")
            list.append(cellModel0)
        }
        for item in model.occupyFeeDetails {
            let timeStr = item.periodStart + "~" + item.periodEnd
            let detailStr = "$\(item.price)/min, Total of \(item.minutes)min"
            let cellModel = GXChargingOrderLRTextCell.Model(leftText: timeStr, rightText: detailStr, 
                                                            leftColor: .gx_orange, rightColor: .gx_orange)
            list.append(cellModel)
        }
        self.tableList = list
    }
}

extension GXChargingOrderDetailsCell3: SkeletonTableViewDataSource {
    // MARK: - SkeletonTableViewDataSource
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return GXChargingOrderLRTextCell.reuseIdentifier
    }
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        let cell: GXChargingOrderLRTextCell = skeletonView.dequeueReusableCell(for: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXChargingOrderLRTextCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bindCell(model: self.tableList[indexPath.row])
        return cell
    }
}
