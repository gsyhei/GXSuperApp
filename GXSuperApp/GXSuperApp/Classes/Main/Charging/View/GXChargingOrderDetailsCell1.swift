//
//  GXChargingOrderDetailsCell1.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/6.
//

import UIKit
import Reusable
import XCGLogger
import SkeletonView

class GXChargingOrderDetailsCell1: UITableViewCell, NibReusable {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var stateRightLC: NSLayoutConstraint!
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
    var isShowOpen: Bool = false {
        didSet {
            self.openButton.isHidden = !isShowOpen
            self.stateRightLC.constant = isShowOpen ? 40 : 24
        }
    }
    var isOpen: Bool = false {
        didSet {
            self.openButton.isSelected = isOpen
        }
    }
    var openAction: GXActionBlockItem<Bool>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
        self.isShowOpen = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindDetailCell(model: GXChargingOrderDetailData?) {
        guard let model = model else { return }
        self.nameLabel.text = model.stationName
        self.stateLabel.isHidden = true
        
        let cellModel0 = GXChargingOrderLRTextCell.Model(leftText: "Pile ID", rightText: model.qrcode)
        let cellModel1 = GXChargingOrderLRTextCell.Model(leftText: "Order ID", rightText: model.orderNo, isShowCopy: true)
        let cellModel2 = GXChargingOrderLRTextCell.Model(leftText: "Start Time", rightText: model.startTime)
        let cellModel3 = GXChargingOrderLRTextCell.Model(leftText: "End Time", rightText: model.endTime)
        self.tableList = [cellModel0, cellModel1, cellModel2, cellModel3]
    }
    
    func bindListCell(model: GXChargingOrderDetailData?) {
        guard let model = model else { return }
        self.nameLabel.text = model.stationName
        self.stateLabel.isHidden = false
        
        let cellModel0 = GXChargingOrderLRTextCell.Model(leftText: "Pile ID", rightText: model.qrcode)
        let cellModel1 = GXChargingOrderLRTextCell.Model(leftText: "Order ID", rightText: model.orderNo, isShowCopy: true)
        let cellModel2 = GXChargingOrderLRTextCell.Model(leftText: "Start Time", rightText: model.startTime)
        var cellList = [cellModel0, cellModel1, cellModel2]
        //订单状态；CHARGING：充电中，OCCUPY：占位中，TO_PAY：待支付，FINISHED：已完成
        switch model.orderStatus {
        case "CHARGING":
            self.stateLabel.textColor = .gx_green
            self.stateLabel.text = "Charging"
        case "OCCUPY":
            self.stateLabel.textColor = .gx_orange
            self.stateLabel.text = "Occupied"
        case "TO_PAY":
            self.stateLabel.textColor = .gx_red
            self.stateLabel.text = "Unpaid"
        case "FINISHED":
            self.stateLabel.textColor = .gx_drakGray
            self.stateLabel.text = "Completed"
        default: break
        }
        if model.orderStatus != "CHARGING" {
            let cellModel3 = GXChargingOrderLRTextCell.Model(leftText: "End Time", rightText: model.endTime)
            cellList.append(cellModel3)
            if !model.occupyStartTime.isEmpty {
                let cellModel4 = GXChargingOrderLRTextCell.Model(leftText: "Start Occupying", rightText: model.occupyStartTime)
                cellList.append(cellModel4)
            }
            if !model.occupyEndTime.isEmpty {
                let cellModel5 = GXChargingOrderLRTextCell.Model(leftText: "End Occupying", rightText: model.occupyEndTime)
                cellList.append(cellModel5)
            }
        }
        if !model.carNumber.isEmpty {
            let cellModel = GXChargingOrderLRTextCell.Model(leftText: "Vehicle", rightText: model.carNumber.formatCarNumber)
            cellList.append(cellModel)
        }
        self.tableList = cellList
    }
    
}

private extension GXChargingOrderDetailsCell1 {
    @IBAction func openButtonClicked(_ sender: UIButton) {
        self.isOpen = !sender.isSelected
        self.openAction?(self.isOpen)
    }
}

extension GXChargingOrderDetailsCell1: SkeletonTableViewDataSource {
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
