//
//  GXDate1PickerView.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/29.
//

import UIKit
import XCGLogger

class GXDate1PickerView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var closeButton: UIButton!
    var completion: GXActionBlockItem<Date>?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.closeButton.setBackgroundColor(.gx_green, for: .normal)
        self.datePicker.minimumDate = Date.date(dateString: "1900", format: "yyyy") ?? Date()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.topLeft, .topRight], radius: 12.0)
    }

    @IBAction func okButtonClicked(_ sender: Any?) {
        self.completion?(self.datePicker.date)
        self.hide(animated: true)
        XCGLogger.info("selected date: " + self.datePicker.date.string(format: "yyyy年MM月dd日"))
    }

    @IBAction func closeButtonClicked(_ sender: Any?) {
        self.hide(animated: true)
    }
}
