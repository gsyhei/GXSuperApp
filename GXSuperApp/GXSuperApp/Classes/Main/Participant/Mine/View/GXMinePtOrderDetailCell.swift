//
//  GXMinePtOrderDetailCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/10.
//

import UIKit
import Reusable

class GXMinePtOrderDetailCell: UITableViewCell, NibReusable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    private lazy var title: String = {
        return "订单编号：\n活动编号：\n支付时间：\n实付金额：\n支付方式：\n出票时间："
    }()
    
    private lazy var textAttributes: [NSAttributedString.Key : Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        let textAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_font(size: 15),
            .paragraphStyle: paragraphStyle
        ]
        return textAttributes
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.infoLabel.text = nil

        let titleAtt = NSAttributedString(string: self.title, attributes: self.textAttributes)
        self.titleLabel.attributedText = titleAtt
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXMinePtOrderDetailData?) {
        guard let model = model else { return }
        
        var text: String = model.orderSn
        text += "\n\(model.activityId)"
        text += "\n\(model.paidTime)"
        text += "\n" + String(format: "￥%.2f", model.totalPrice)
        text += "\n" + ((model.paidType == 1) ? "支付宝":"微信") //1-支付宝 2-微信
        text += "\n\(model.ticketTime)"

        let infoAtt = NSAttributedString(string: text, attributes: self.textAttributes)
        self.infoLabel.attributedText = infoAtt
    }
}
