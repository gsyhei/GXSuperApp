//
//  GXTimePickerView.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/1.
//

import UIKit
import XCGLogger

class GXTimePickerView: UIView {
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var closeButton: UIButton!
    var completion: GXActionBlockItem<String>?

    private lazy var list: [String] = {
        var timesArr: [String] = []
        for index in 0...23 {
            timesArr.append(String(format: "%02d:00", index))
            timesArr.append(String(format: "%02d:30", index))
        }
        return timesArr
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.closeButton.setBackgroundColor(.gx_green, for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.topLeft, .topRight], radius: 12.0)
    }

    @IBAction func okButtonClicked(_ sender: Any?) {
        let selectedIndex = self.timePicker.selectedRow(inComponent: 0)
        let selectedTime = self.list[selectedIndex]
        self.completion?(selectedTime)
        self.hide(animated: true)
        XCGLogger.info("selected time: " + selectedTime)
    }

    @IBAction func closeButtonClicked(_ sender: Any?) {
        self.hide(animated: true)
    }

    func showSelectedTime(_ time: String?) {
        guard let time = time else { return }
        let index = self.list.firstIndex(where: {$0 == time})
        guard let index = index else { return }
        self.timePicker.selectRow(index, inComponent: 0, animated: true)
    }
}

extension GXTimePickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.list.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.list[row]
    }

}
