//
//  GXHorizontalCalendarDayView.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/8.
//

import UIKit
import RxSwift

class GXHorizontalCalendarDayView: UICollectionView {
    private var disposeBag = DisposeBag()
    var viewModel: GXHorizontalCalendarDaysModel?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = .clear
        self.register(cellType: GXHorizontalCalendarDayCell.self)
        self.delegate = self;
        self.dataSource = self;
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false

        NotificationCenter.default.rx
            .notification(GX_NotifName_HCalendarSelected)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                if let dates = notifi.object as? [Date] {
                    self?.selectedDates(dates: dates)
                }
            }).disposed(by: disposeBag)
    }
    
    func bindViewModel(viewModel: GXHorizontalCalendarDaysModel) {
        self.viewModel = viewModel
        self.superview?.setNeedsLayout()
        self.superview?.layoutIfNeeded()
        let indexPath = IndexPath(item: viewModel.todayIndex, section: 0)
        self.reloadData()
        let attributes = self.layoutAttributesForItem(at: indexPath)
        self.contentOffset = CGPoint(x: attributes?.frame.origin.x ?? 0, y: 0)
    }

    func selectedDates(dates: [Date]) {
        var beginToDate: Date? = nil
        if dates.count == 2 {
            beginToDate = min(dates[0], dates[1])
        }  else if dates.count == 1 {
            beginToDate = dates[0]
        }
        guard let beginDate = beginToDate else { return }

        if let index = self.viewModel?.dayList.firstIndex(where: { model in
            return model.date == beginDate
        }) {
            let indexPath = IndexPath(item: index, section: 0)
            self.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
}

extension GXHorizontalCalendarDayView: UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.dayList.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GXHorizontalCalendarDayCell = collectionView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel?.dayList[indexPath.item]
        cell.model = model
        cell.selectedDates(dates: self.viewModel?.selectedDates ?? [])
        if let dotsDict = self.viewModel?.dotsDict, dotsDict.keys.count > 0 {
            cell.updateRedDot(dotsDict: dotsDict)
        }
        return cell
    }
}

extension GXHorizontalCalendarDayView: UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((SCREEN_WIDTH - 32.0) / 7.0)
        return CGSize(width: width, height: 48.0)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }

    // MARK: - UICollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let letViewModel = self.viewModel else { return }
        let model = letViewModel.dayList[indexPath.item]

        if letViewModel.selectedDates.count >= 2 {
            letViewModel.selectedDates.removeAll()
        }
        else if letViewModel.selectedDates.count == 1 {
            if model.date == letViewModel.selectedDates.first {
                letViewModel.selectedDates.removeAll()
                NotificationCenter.default.post(name: GX_NotifName_HCalendarSelected, object: letViewModel.selectedDates)
                return
            }
        }
        letViewModel.selectedDates.append(model.date)
        NotificationCenter.default.post(name: GX_NotifName_HCalendarSelected, object: letViewModel.selectedDates)
    }

}
