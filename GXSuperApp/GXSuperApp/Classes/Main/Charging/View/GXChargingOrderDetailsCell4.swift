//
//  GXChargingOrderDetailsCell4.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/8.
//

import UIKit
import Reusable

class GXChargingOrderDetailsCell4: UITableViewCell, NibReusable {
    @IBOutlet weak var tableHeightLC: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration()
            tableView.dataSource = self
            tableView.rowHeight = 34
            tableView.register(cellType: GXChargingOrderLRTextCell.self)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var count: Int = 3
    func bindCell(count: Int) {
        self.count = count
        self.tableHeightLC.constant = tableView.rowHeight * CGFloat(count)
    }
}

extension GXChargingOrderDetailsCell4: UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXChargingOrderLRTextCell = tableView.dequeueReusableCell(for: indexPath)
        return cell
    }
}
