//
//  GXPtActivityPaySuccQRCodeCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/1.
//

import UIKit
import Reusable

class GXPtActivityPaySuccQRCodeCell: UITableViewCell, NibReusable {
    @IBOutlet weak var topIView: UIImageView!
    @IBOutlet weak var topConView: UIView!
    @IBOutlet weak var statusIView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var qrcodeImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        let colors: [UIColor] = [
            .hexWithAlpha(hexString: "#63F67B", alpha: 1.0),
            .hexWithAlpha(hexString: "#333333", alpha: 1.0)
        ]
        let image = UIImage(gradientColors: colors, style: .horizontal)
        self.statusIView.image = image
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.topConView.setRoundedCorners([.bottomLeft, .bottomRight], radius: 16.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXSignActivityData?) {
        guard let model = model else {
            self.statusLabel.text = "预报名成功"
            self.infoLabel.isHidden = false
            self.qrcodeImageView.isHidden = true
            return
        }
        if model.ticketCode.count > 0 {
            self.infoLabel.isHidden = true
            self.qrcodeImageView.isHidden = false
            // 门票状态 0-未使用 1-已使用 2-平台禁用 3-已过期
            self.statusLabel.text = "未使用"
            let colors: [UIColor] = [
                .hexWithAlpha(hexString: "#63F67B", alpha: 1.0),
                .hexWithAlpha(hexString: "#333333", alpha: 1.0)
            ]
            let image = UIImage(gradientColors: colors, style: .horizontal)
            self.statusIView.image = image
            self.topConView.backgroundColor = .gx_black
            self.topIView.image = UIImage(named: "pt_qrcode_xb")

            let qrCodeString = GXUtil.gx_qrCode(type: .ticket, text: model.ticketCode)
            UIImage.createQRCodeImage(text: qrCodeString) {[weak self] image in
                self?.qrcodeImageView.image = image
            }
        }
        else {
            self.statusLabel.text = "预报名成功"
            self.infoLabel.isHidden = false
            self.qrcodeImageView.isHidden = true
        }
    }

    func bindCell(model: GXMinePtOrderDetailData?) {
        guard let model = model else { return }
        
        self.infoLabel.isHidden = true
        self.qrcodeImageView.isHidden = false
        // 门票状态 0-未使用 1-已使用 2-平台禁用 3-已过期
        let statusTexts: [String] = ["未使用", "已使用", "平台禁用", "已过期"]
        let statusText = (model.ticketStatus < statusTexts.count) ? statusTexts[model.ticketStatus]:""
        self.statusLabel.text = statusText

        if model.ticketStatus == 0 {
            let colors: [UIColor] = [
                .hexWithAlpha(hexString: "#63F67B", alpha: 1.0),
                .hexWithAlpha(hexString: "#333333", alpha: 1.0)
            ]
            let image = UIImage(gradientColors: colors, style: .horizontal)
            self.statusIView.image = image
            self.topConView.backgroundColor = .gx_black
            self.topIView.image = UIImage(named: "pt_qrcode_xb")
        }
        else {
            let colors: [UIColor] = [
                .hexWithAlpha(hexString: "#9F9F9F", alpha: 1.0),
                .hexWithAlpha(hexString: "#999999", alpha: 1.0)
            ]
            let image = UIImage(gradientColors: colors, style: .horizontal)
            self.statusIView.image = image
            self.topConView.backgroundColor = .gx_gray
            self.topIView.image = UIImage(named: "pt_qrcode_xbhs")
        }
        let qrCodeString = GXUtil.gx_qrCode(type: .ticket, text: model.ticketCode)
        UIImage.createQRCodeImage(text: qrCodeString) {[weak self] image in
            self?.qrcodeImageView.image = image
        }
    }
    
}
