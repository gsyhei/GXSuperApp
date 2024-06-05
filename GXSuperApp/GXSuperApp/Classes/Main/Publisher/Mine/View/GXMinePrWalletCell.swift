//
//  GXMinePrWalletCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/12.
//

import UIKit
import Reusable

class GXMinePrWalletCell: UITableViewCell, NibReusable {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var lookLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.dateLabel.text = nil
        self.statusLabel.text = nil
        self.priceLabel.text = nil
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.lookLabel.textColor = highlighted ? .gx_lightGray:.gx_black
    }
    
    func bindCell(model: GXFundjoursItem?) {
        guard let model = model else { return }

        var dateText = model.createTime.replacingOccurrences(of: "\n", with: " ")
        dateText = dateText.replacingOccurrences(of: "-", with: ".")
        self.dateLabel.text = dateText

        // 委托类型 0-订单收入 1-提现 2-其它
        // businessFlag
        // 处理结果 1-成功 0-失败
        // processResult
        if model.businessFlag == 0 {
            self.statusLabel.text = "买票收入"
        }
        else if model.businessFlag == 1 {
            if let processResult = model.processResult {
                self.statusLabel.text = processResult ? "提现已通过":"提现未通过"
            }
            else {
                self.statusLabel.text = "提现审核中"
            }
        }
        else {
            self.statusLabel.text = "其它"
        }
        
        let attributedString = NSMutableAttributedString()
        let balanceText = String(format: "%.2f", model.entrustBalance)
        if model.entrustBalance >= 0 {
            let redAttributes: [NSAttributedString.Key : Any] = [
                .font: UIFont.gx_font(size: 15),
                .foregroundColor: UIColor.gx_red
            ]
            let titleAtt = NSAttributedString(string: "+" + balanceText, attributes: redAttributes)
            attributedString.append(titleAtt)
        }
        else {
            let greenAttributes: [NSAttributedString.Key : Any] = [
                .font: UIFont.gx_font(size: 15),
                .foregroundColor: UIColor.gx_drakGreen
            ]
            let titleAtt = NSAttributedString(string: "-" + balanceText, attributes: greenAttributes)
            attributedString.append(titleAtt)
        }
        if model.businessFlag == 1 {
            let blackAttributes: [NSAttributedString.Key : Any] = [
                .font: UIFont.gx_font(size: 13),
                .foregroundColor: UIColor.gx_black
            ]
            let abbalanceText = String(format: "\n-%.2f手续费", model.fee)
            let titleAtt = NSAttributedString(string: abbalanceText, attributes: blackAttributes)
            attributedString.append(titleAtt)
        }
        self.priceLabel.attributedText = attributedString
    }
}
