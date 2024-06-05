//
//  GXDatePickerView.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/30.
//

import UIKit
import GXAlert_Swift
import XCGLogger

class GXDatePickerView: UIView {
    @IBOutlet weak var datePicker: GXVerticalCalendarSingleDayView!
    @IBOutlet weak var closeButton: UIButton!
    var completion: GXActionBlockItem<Date>?

    func setSelectedDate(_ date: Date? = nil, minSelectDate: Date? = nil, maxSelectDate: Date? = nil) {
        var minDate = minSelectDate
        if minDate == nil {
            minDate = GXServiceManager.shared.systemDate
        }
        let vm = GXHorizontalCalendarDaysModel(date: GXServiceManager.shared.systemDate,
                                               minSelectDate: minDate,
                                               maxSelectDate: maxSelectDate)
        if let selectedDate = date {
            vm.selectedDates = [selectedDate]
        }
        self.datePicker.bindViewModel(viewModel: vm)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.closeButton.setBackgroundColor(.gx_green, for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.topLeft, .topRight], radius: 12.0)
    }

    @IBAction func okButtonClicked(_ sender: Any?) {
        if let selectedDate = self.datePicker.selectedDates.first {
            self.completion?(selectedDate)
            self.hide(animated: true)
            XCGLogger.info("selected date: " + selectedDate.string(format: "yyyy年MM月dd日"))
        }
    }

    @IBAction func closeButtonClicked(_ sender: Any?) {
        self.hide(animated: true)
    }
}
