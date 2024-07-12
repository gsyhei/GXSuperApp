//
//  GXMineCell1.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import Reusable

class GXMineCell1: UITableViewCell, NibReusable {
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var orderNumLabel: UILabel!
    
    var action: GXActionBlockItem<Int>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(data: GXWalletConsumerBalanceData?, orderTotal: Int, action: GXActionBlockItem<Int>?) {
        self.action = action
        self.orderNumLabel.text = "\(orderTotal)"
        guard let data = data else { return }
        self.balanceLabel.text = String(format: "$ %.2f", data.available)
    }
    
    @IBAction func leftButtonClicked(_ sender: UIButton) {
        self.action?(0)
    }
    
    @IBAction func rightButtonClicked(_ sender: UIButton) {
        self.action?(1)
    }
}
