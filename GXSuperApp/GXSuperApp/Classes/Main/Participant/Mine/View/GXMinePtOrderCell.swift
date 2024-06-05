//
//  GXMinePtOrderCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/10.
//

import UIKit
import Reusable

class GXMinePtOrderCell: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var activityTypeNameLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityOrderLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        self.activityNameLabel.text = nil
        self.activityTypeNameLabel.text = nil
        self.activityOrderLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.containerView.backgroundColor = highlighted ? .gx_lightGray:.white
    }

    func bindCell(model: GXListMyOrderItem?) {
        guard let data = model else { return }

        let imageUrlArr = data.listPics.components(separatedBy: ",")
        if let imageUrlStr = imageUrlArr.first, imageUrlStr.count > 0 {
            self.activityImageView.kf.setImage(with: URL(string: imageUrlStr), placeholder: UIImage.gx_defaultActivityIcon)
        } else {
            self.activityImageView.kf.setImage(with: URL(string: data.listPics), placeholder: UIImage.gx_defaultActivityIcon)
        }
        self.activityTypeNameLabel.text = data.activityTypeName

        self.activityNameLabel.text = data.activityName
        
        let time = (data.paidTime.count > 0) ? data.paidTime:data.updateTime
        var orderText = "订单编号 \(data.orderSn)\n"
        orderText += "支付时间 \(time)\n"
        orderText += String(format: "实付金额 ¥%.2f", data.totalPrice)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        let titleAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_font(size: 13),
            .foregroundColor: UIColor.gx_drakGray,
            .paragraphStyle: paragraphStyle
        ]
        self.activityOrderLabel.attributedText = NSAttributedString(string: orderText, attributes: titleAttributes)
    }
    
}

