//
//  GXHorizontalCalendarDayCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/8.
//

import UIKit
import Reusable
import RxSwift

class GXHorizontalCalendarDayCell: UICollectionViewCell, Reusable {
    private var disposeBag = DisposeBag()

    public lazy var dayLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.textColor = .gx_textBlack
        label.font = .gx_boldFont(size: 13)

        return label
    }()

    public lazy var weekLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.textColor = .gx_textBlack
        label.font = .gx_font(size: 11)

        return label
    }()

    public lazy var dotView: UIView = {
        return UIView(frame: CGRect(origin: .zero, size: CGSize(width: 6, height: 6))).then {
            $0.backgroundColor = .gx_red
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 3
            $0.isHidden = true
        }
    }()

    public var model: GXCalendarDayModel? {
        didSet {
            if let letModel = self.model {
                self.dayLabel.text = GXCalendar.gx_monthDay(components: letModel.components)
                if letModel.isToday {
                    self.weekLabel.text = "今天"
                } else {
                    self.weekLabel.text = GXCalendar.gx_weekDay(components: letModel.components, weekType: 1)
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.dayLabel)
        self.contentView.addSubview(self.weekLabel)
        self.contentView.addSubview(self.dotView)

        self.dayLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.contentView.snp.centerY).offset(-1)
        }
        self.weekLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.contentView.snp.centerY).offset(1)
        }
        self.dotView.snp.makeConstraints { make in
            make.top.equalTo(self.dayLabel.snp.top).offset(-3)
            make.left.equalTo(self.dayLabel.snp.left).offset(-3)
            make.size.equalTo(CGSize(width: 6, height: 6))
        }

        NotificationCenter.default.rx
            .notification(GX_NotifName_HCalendarSelected)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                if let dates = notifi.object as? [Date] {
                    self?.selectedDates(dates: dates)
                }
            }).disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.dayLabel.text = nil
        self.weekLabel.text = nil
        self.dotView.isHidden = true
        self.contentView.backgroundColor = .white
        self.contentView.setRoundedCorners([.allCorners], radius: 0.0)
    }

    func selectedDates(dates: [Date]) {
        guard let cellDate = self.model?.date else { return }

        if dates.count == 2 {
            var beginDate: Date, endDate: Date
            if dates[0] > dates[1] {
                beginDate = dates[1]; endDate = dates[0]
            } else {
                beginDate = dates[0]; endDate = dates[1]
            }
            if beginDate == cellDate {
                self.contentView.backgroundColor = .gx_green
                self.contentView.setRoundedCorners([.topLeft, .bottomLeft], radius: 8.0)
            }
            else if endDate == cellDate {
                self.contentView.backgroundColor = .gx_green
                self.contentView.setRoundedCorners([.topRight, .bottomRight], radius: 8.0)
            }
            else {
                if cellDate > beginDate && cellDate < endDate {
                    self.contentView.backgroundColor = .gx_lightGreen
                    self.contentView.setRoundedCorners([.allCorners], radius: 0.0)
                }
                else {
                    self.contentView.backgroundColor = .white
                    self.contentView.setRoundedCorners([.allCorners], radius: 0.0)
                }
            }
        }
        else if dates.count == 1 {
            if cellDate == dates.first {
                self.contentView.backgroundColor = .gx_green
                self.contentView.setRoundedCorners([.allCorners], radius: 8.0)
            }
            else {
                self.contentView.backgroundColor = .white
                self.contentView.setRoundedCorners([.allCorners], radius: 0.0)
            }
        }
        else {
            self.contentView.backgroundColor = .white
            self.contentView.setRoundedCorners([.allCorners], radius: 0.0)
        }
    }
    
    func updateRedDot(dotsDict: Dictionary<String, Set<String>>) {
        self.dotView.isHidden = true
        guard let model = self.model else { return }
        guard !model.isCurrentMonthOut else { return }
        guard let dotsKey = dotsDict.keys.first(where: { model.dateString.contains(find: $0) }) else { return }
        guard let dotsList = dotsDict[dotsKey] else { return }
        if dotsList.contains(where: { $0 == model.dateString }) {
            self.dotView.isHidden = false
        }
    }
}
