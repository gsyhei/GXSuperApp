//
//  GXPtActivityOrderCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/13.
//

import UIKit
import Reusable
import GXBanner

class GXPtActivityOrderCell: UITableViewCell, NibReusable {
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityDateLabel: UILabel!
    @IBOutlet weak var activityAddressLabel: UILabel!
    @IBOutlet weak var activityAddressDescLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!

    var locationAction: GXActionBlock?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.activityNameLabel.text = nil
        self.activityDateLabel.text = nil
        self.activityAddressLabel.text = nil
        self.activityAddressDescLabel.text = nil
        self.priceLabel.text = nil
    }

    func bindModel(data: GXActivityBaseInfoData?, totalPrice: Float? = nil, isHiddenLocation: Bool = false) {
        self.locationButton.isHidden = isHiddenLocation
        self.locationLabel.isHidden = isHiddenLocation
        guard let model = data else { return }

        self.activityNameLabel.text = model.activityName
        self.activityDateLabel.text = model.startToEndDateString()
        self.activityAddressLabel.text = model.showCityName()
        self.activityAddressDescLabel.text = model.showAddress()
        if let price = totalPrice {
            self.priceLabel.text = String(format: "￥%.2f", price)
        } else {
            self.priceLabel.text = "免费"
        }

        let distance = GXLocationManager.shared.getUserDistanceTo(latitude:model.latitude, longitude: model.longitude)
        self.locationLabel.text = distance
    }

    func bindCell(model: GXMinePtOrderDetailData?) {
        guard let model = model else { return }

        self.activityNameLabel.text = model.activityName
        self.activityDateLabel.text = model.startToEndDateString()
        self.activityAddressLabel.text = model.showCityName()
        self.activityAddressDescLabel.text = model.showAddress()
        self.priceLabel.text = String(format: "￥%.2f", model.totalPrice)

        let distance = GXLocationManager.shared.getUserDistanceTo(latitude:model.latitude, longitude: model.longitude)
        self.locationLabel.text = distance
    }
}

extension GXPtActivityOrderCell {
    @IBAction func locationButtonClicked(_ sender: UIButton) {
        self.locationAction?()
    }
}
