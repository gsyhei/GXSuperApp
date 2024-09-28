//
//  GXChargingOrderDetailsCell4.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/8.
//

import UIKit
import Reusable
import SkeletonView

class GXChargingOrderDetailsCell4: UITableViewCell, NibReusable {
    @IBOutlet weak var tableHeightLC: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration()
            tableView.dataSource = self
            tableView.estimatedRowHeight = 34
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
        
        let cellModel0 = GXChargingOrderLRTextCell.Model(leftText: "Due Amount", rightText: "$\(model.totalFee)")
        let cellModel1 = GXChargingOrderLRTextCell.Model(leftText: "Paid Amount", rightText: "$\(model.actualFee)")
        let cellModel2 = GXChargingOrderLRTextCell.Model(leftText: "Payment Time", rightText: model.payTime)
        let payType: String = (model.payType == .HOLD) ? "Credit Card":"Balance"
        let cellModel3 = GXChargingOrderLRTextCell.Model(leftText: "Payment Channel", rightText: payType)
        self.tableList = [cellModel0, cellModel1, cellModel2, cellModel3]
    }
}

extension GXChargingOrderDetailsCell4: SkeletonTableViewDataSource {
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
