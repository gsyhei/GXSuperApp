//
//  GXChargingOrderDetailsCell10.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/9.
//

import UIKit
import Reusable

class GXChargingOrderDetailsCell10: UITableViewCell, NibReusable {
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    private var section: Int = 0
    private var buttonAction: GXActionBlockItem3<GXChargingOrderDetailsCell10, UIButton, Int>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXChargingOrderDetailData?, section: Int, action: GXActionBlockItem3<GXChargingOrderDetailsCell10, UIButton, Int>?) {
        guard let model = model else { return }
        
        self.section = section
        self.buttonAction = action
        self.leftButton.layer.borderColor = nil
        self.leftButton.layer.borderWidth = 0
        self.rightButton.layer.borderColor = nil
        self.rightButton.layer.borderWidth = 0
        
        // 订单状态；CHARGING：充电中，OCCUPY：占位中，TO_PAY：待支付，FINISHED：已完成
        switch model.orderStatus {
        case .CHARGING:
            self.leftButton.isHidden = true
            self.rightButton.isHidden = false
            self.rightButton.setTitle("View", for: .normal)
            self.rightButton.setTitleColor(.white, for: .normal)
            self.rightButton.setBackgroundColor(.gx_green, for: .normal)
            self.rightButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        case .OCCUPY:
            self.leftButton.isHidden = true
            self.rightButton.isHidden = false
            self.rightButton.setTitle("View", for: .normal)
            self.rightButton.setTitleColor(.white, for: .normal)
            self.rightButton.setBackgroundColor(.gx_green, for: .normal)
            self.rightButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        case .TO_PAY:
            self.leftButton.isHidden = false
            self.leftButton.setTitle("More", for: .normal)
            self.leftButton.setTitleColor(.gx_green, for: .normal)
            self.leftButton.setBackgroundColor(.white, for: .normal)
            self.leftButton.setBackgroundColor(.gx_background, for: .highlighted)
            self.leftButton.layer.borderColor = UIColor.gx_green.cgColor
            self.leftButton.layer.borderWidth = 1.0
            self.rightButton.isHidden = false
            self.rightButton.setTitle("Pay", for: .normal)
            self.rightButton.setTitleColor(.white, for: .normal)
            self.rightButton.setBackgroundColor(.gx_green, for: .normal)
            self.rightButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        case .FINISHED:
            self.leftButton.isHidden = false
            self.leftButton.setTitle("More", for: .normal)
            self.leftButton.setTitleColor(.gx_green, for: .normal)
            self.leftButton.setBackgroundColor(.white, for: .normal)
            self.leftButton.setBackgroundColor(.gx_background, for: .highlighted)
            self.leftButton.layer.borderColor = UIColor.gx_green.cgColor
            self.leftButton.layer.borderWidth = 1.0
            self.rightButton.isHidden = false
            self.rightButton.setTitle("View", for: .normal)
            self.rightButton.setTitleColor(.white, for: .normal)
            self.rightButton.setBackgroundColor(.gx_green, for: .normal)
            self.rightButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        default: break
        }
    }
}

extension GXChargingOrderDetailsCell10 {
    @IBAction func leftButtonClicked(_ sender: UIButton) {
        self.buttonAction?(self, sender, self.section)
    }
    @IBAction func rightButtonClicked(_ sender: UIButton) {
        self.buttonAction?(self, sender, self.section)
    }
}
