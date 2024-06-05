//
//  GXVerticalCalendarMenu.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/9.
//

import UIKit
import XCGLogger

class GXVerticalCalendarMenu: UIView {

    lazy var calendarDayView: GXVerticalCalendarDayView = {
        var frame = self.bounds
        frame.size.height -= 60.0
        return GXVerticalCalendarDayView(_frame: frame)
    }()

    lazy var resetButton: UIButton = {
        return UIButton(type: .custom).then {
            let top = self.bounds.height - 50
            $0.frame = CGRect(origin: CGPoint(x: 16, y: top), size: CGSize(width: 120, height: 40))
            $0.setTitle("重置", for: .normal)
            $0.setTitleColor(.gx_textBlack, for: .normal)
            $0.setBackgroundColor(.gx_green, for: .normal)
            $0.titleLabel?.font = .gx_font(size: 17)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8.0
            $0.addTarget(self, action: #selector(resetButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    lazy var confirmButton: UIButton = {
        return UIButton(type: .custom).then {
            let top = self.bounds.height - 50
            let width = self.bounds.width - 162
            $0.frame = CGRect(origin: CGPoint(x: 146, y: top), size: CGSize(width: width, height: 40))
            $0.setTitle("确定", for: .normal)
            $0.setTitleColor(.gx_textBlack, for: .normal)
            $0.setBackgroundColor(.gx_green, for: .normal)
            $0.titleLabel?.font = .gx_font(size: 17)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8.0
            $0.addTarget(self, action: #selector(confirmButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    deinit {
        XCGLogger.info("GXVerticalCalendarMenu deinit")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(self.calendarDayView)
        self.addSubview(self.confirmButton)
        self.addSubview(self.resetButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.bottomLeft, .bottomRight], radius: 16.0)
    }
}

extension GXVerticalCalendarMenu {
    @objc func resetButtonClicked(_ sender: UIButton) {
        self.calendarDayView.selectedDates.removeAll()
        NotificationCenter.default.post(name: GX_NotifName_VCalendarSelected, object: self.calendarDayView.selectedDates)
    }

    @objc func confirmButtonClicked(_ sender: UIButton) {
        self.calendarDayView.viewModel?.selectedDates = self.calendarDayView.selectedDates
        NotificationCenter.default.post(name: GX_NotifName_HCalendarSelected, object: self.calendarDayView.viewModel?.selectedDates)
        self.hide(animated: true)
    }
}
