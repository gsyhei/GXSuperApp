//
//  GXMineStatementCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import Reusable

class GXMineStatementCell: UITableViewCell, NibReusable {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXWalletConsumerListRowsItem?) {
        guard let model = model else { return }
        
        self.dateLabel.text = model.createTime
        //类别；RECHARGE：充值，CHARGING：充电消费；REFUND：订单退款，OCCUPY_REFUND：占位费退款，WITHDRAW：提现，WITHDRAW_FAILED：提现失败
        switch model.type {
        case "RECHARGE":
            self.contentLabel.text = "Recharge"
        case "CHARGING":
            self.contentLabel.text = "Charging Consumption"
        case "REFUND":
            self.contentLabel.text = "Order Refund"
        case "OCCUPY_REFUND":
            self.contentLabel.text = "Idle Fee Refund"
        case "WITHDRAW":
            self.contentLabel.text = "Withdraw"
        case "WITHDRAW_FAILED":
            self.contentLabel.text = "Withdrawal Failed"
        default: break
        }
        if model.direction == "OUT" {
            self.amountLabel.textColor = .gx_drakGray
            self.amountLabel.text = String(format: "-$%.2f", abs(model.amount))
        } else {
            self.amountLabel.textColor = .gx_green
            self.amountLabel.text = String(format: "+$%.2f", abs(model.amount))
        }
    }
        
}
