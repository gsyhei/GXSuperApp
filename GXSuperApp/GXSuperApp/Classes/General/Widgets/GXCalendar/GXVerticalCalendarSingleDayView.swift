//
//  GXVerticalCalendarSingleDayView.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/19.
//

import UIKit
import RxSwift
import SnapKitExtend

class GXVerticalCalendarSingleDayView: UIView {
    private var disposeBag = DisposeBag()
    var viewModel: GXHorizontalCalendarDaysModel?
    public var selectedDates: [Date] = []

    lazy var weakLabels: [UILabel] = {
        var labels: [UILabel] = []
        for week in 1...7  {
            let weekStr = GXCalendar.gx_weekDay(week: week)
            let label = UILabel(frame: CGRect.zero)
            label.textAlignment = .center
            label.text = weekStr
            label.font = .gx_boldFont(size: 14)
            if week == 1 || week == 7 {
                label.textColor = .gx_gray
            }
            else {
                label.textColor = .gx_textBlack
            }
            labels.append(label)
        }
        return labels
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        let frame = CGRect(x: 0, y: 28, width: SCREEN_WIDTH, height: self.frame.height - 28)
        return UICollectionView(frame: frame, collectionViewLayout: layout).then {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.register(supplementaryViewType: GXVerticalCalendarDayHeader.self,
                        ofKind: UICollectionView.elementKindSectionHeader)
            $0.register(cellType: GXVerticalCalendarDayCell.self)
            $0.dataSource = self
            $0.delegate = self
        }
    }()

    convenience init(_frame: CGRect) {
        self.init(frame: _frame)
        self.createSubviews()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.createSubviews()
    }

    func createSubviews() {
        self.backgroundColor = .white
        self.addSubview(self.collectionView)

        for label in self.weakLabels {
            self.addSubview(label)
        }
        self.weakLabels.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalTo(28)
        }
        self.weakLabels.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0, leadSpacing: 10, tailSpacing: 10)

        NotificationCenter.default.rx
            .notification(GX_NotifName_VCalendarSelected)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                if let dates = notifi.object as? [Date] {
                    self?.selectedLinkageDates(dates: dates)
                }
            }).disposed(by: disposeBag)
    }

    func bindViewModel(viewModel: GXHorizontalCalendarDaysModel) {
        self.viewModel = viewModel
        self.selectedDates = self.viewModel?.selectedDates ?? []
        self.collectionView.reloadData()
        self.layoutIfNeeded()
        self.selectedLinkageDates(dates: self.selectedDates, isInit: true)
    }

    func selectedLinkageDates(dates: [Date], isInit: Bool = false) {
        var beginToDate: Date? = nil
        if dates.count == 2 {
            beginToDate = min(dates[0], dates[1])
        } else if dates.count == 1 {
            beginToDate = dates[0]
        } else if isInit {
            beginToDate = self.viewModel?.todayDate
        }
        guard let beginDate = beginToDate else { return }
        guard let sectionCount = self.viewModel?.monthDayList.count else { return }

        for section in 0..<sectionCount {
            guard let model = self.viewModel?.monthDayList[section] else { continue }
            if let index = model.dayList.firstIndex(where: { model in
                return !model.isCurrentMonthOut && Calendar.current.isDate(model.date, inSameDayAs: beginDate)
            }) {
                let indexPath = IndexPath(item: index, section: section)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                break
            }
        }
    }

}

extension GXVerticalCalendarSingleDayView: UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel?.monthDayList.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.monthDayList[section].dayList.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GXVerticalCalendarDayCell = collectionView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel?.monthDayList[indexPath.section].dayList[indexPath.item]
        cell.model = model
        cell.selectedDates(dates: self.selectedDates)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        let header: GXVerticalCalendarDayHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
        let model = self.viewModel?.monthDayList[indexPath.section]
        header.dateLabel.text = model?.monthDate.string(format: "yyyy年MM月")

        return header
    }
}

extension GXVerticalCalendarSingleDayView: UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let rowCount: Int = 7
        let width = Int(collectionView.width - 20) / rowCount

        return CGSize(width: width, height: 64)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.width, height: 28)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 10, bottom: 0, right: 10)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

    // MARK: - UICollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let model = self.viewModel?.monthDayList[indexPath.section].dayList[indexPath.item]

        return !(model?.isCurrentMonthOut ?? false) && !(model?.canNotSelect ?? false)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = self.viewModel?.monthDayList[indexPath.section].dayList[indexPath.item] else { return }

        self.selectedDates = [model.date]
        NotificationCenter.default.post(name: GX_NotifName_VCalendarSelected, object: self.selectedDates)
    }

}



