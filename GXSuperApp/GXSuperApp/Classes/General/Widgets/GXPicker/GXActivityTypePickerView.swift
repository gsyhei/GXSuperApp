//
//  GXActivityTypePickerView.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/27.
//

import UIKit
import Reusable
import MBProgressHUD
import CollectionKit

class GXActivityPriceTypeCell: UITableViewCell, Reusable {
    var dataSource = ArrayDataSource<GXSelectItem>()
    var priceType: Int?

    private lazy var collectionView: CollectionView = {
        let width: Int = Int(SCREEN_WIDTH - 48.0) / 3
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: GXSelectItem, index: Int) in
            view.titleLabel?.font = .gx_font(size: 15)
            view.setTitle(data.title, for: .normal)
            view.setTitleColor(.gx_black, for: .normal)
            view.setBackgroundColor(.white, for: .normal)
            view.setBackgroundColor(.gx_green, for: .selected)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 4.0
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor.gx_lightGray.cgColor
            view.isUserInteractionEnabled = false
            view.isSelected = (data.status == self.priceType)
        })
        let sizeSource = { (index: Int, data: GXSelectItem, collectionSize: CGSize) -> CGSize in
            return CGSize(width: width, height: 32)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: {[weak self] tapContext in
                guard let `self` = self else { return }
                for cell in self.collectionView.visibleCells {
                    if let button = cell as? UIButton {
                        button.isSelected = (button == tapContext.view)
                    }
                }
                if tapContext.view.isSelected {
                    self.priceType = tapContext.data.status
                }
            }
        )
        provider.layout = FlowLayout(spacing: 8.0)
        return CollectionView(provider: provider)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindCell(list: [GXSelectItem], priceType: Int?) {
        self.priceType = priceType
        self.dataSource.data = list
    }
}

class GXActivityTypeCell: UITableViewCell, Reusable {
    var dataSource = ArrayDataSource<GXPrHomeListActivityTypeItem>()
    var activityTypeIds: [String] = []

    private lazy var collectionView: CollectionView = {
        let width: Int = Int(SCREEN_WIDTH - 48.0) / 3
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: GXPrHomeListActivityTypeItem, index: Int) in
            view.titleLabel?.font = .gx_font(size: 15)
            view.setTitle(data.activityTypeName, for: .normal)
            view.setTitleColor(.gx_black, for: .normal)
            view.setBackgroundColor(.white, for: .normal)
            view.setBackgroundColor(.gx_green, for: .selected)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 4.0
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor.gx_lightGray.cgColor
            view.isUserInteractionEnabled = false
            if data.id.count == 0 && self.activityTypeIds.count == 0 {
                view.isSelected = true
            } else {
                view.isSelected = (self.activityTypeIds.contains(where: { $0 == data.id }))
            }
        })
        let sizeSource = { (index: Int, data: GXPrHomeListActivityTypeItem, collectionSize: CGSize) -> CGSize in
            return CGSize(width: width, height: 32)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: {[weak self] tapContext in
                guard let `self` = self else { return }
                self.didSelectItem(tapContext: tapContext)
            }
        )
        provider.layout = FlowLayout(spacing: 8.0)
        return CollectionView(provider: provider)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindCell(list: [GXPrHomeListActivityTypeItem], activityTypeIds: [String]) {
        self.activityTypeIds = activityTypeIds
        self.dataSource.data = list
    }

    func didSelectItem(tapContext: BasicProvider<GXPrHomeListActivityTypeItem, UIButton>.TapContext) {
        if tapContext.data.id.count == 0 {
            self.activityTypeIds.removeAll()
        }
        else {
            if let tapIndex = (self.activityTypeIds.firstIndex(where: { $0 == tapContext.data.id })) {
                self.activityTypeIds.remove(at: tapIndex)
            }
            else {
                self.activityTypeIds.append(tapContext.data.id)
            }
        }
        if self.activityTypeIds.count == 0 {
            for index in self.collectionView.visibleIndexes {
                let item = self.dataSource.data(at: index)
                let cell = self.collectionView.cell(at: index) as? UIButton
                cell?.isSelected = (item.id.count == 0)
            }
        }
        else {
            for index in self.collectionView.visibleIndexes {
                let item = self.dataSource.data(at: index)
                let cell = self.collectionView.cell(at: index) as? UIButton
                if (self.activityTypeIds.firstIndex(of: item.id) != nil) {
                    cell?.isSelected = true
                } else {
                    cell?.isSelected = false
                }
            }
        }
    }
}

class GXActivityTypePickerView: UIView {
    var selectedAction: GXActionBlockItem2<[String], Int?>?
    var activityTypeList: [GXPrHomeListActivityTypeItem] = []
    var activityTypeIds: [String] = []
    var priceType: Int?

    lazy var tableView: GXBaseTableView = {
        var rect = self.bounds
        rect.size.height -= 60
        return GXBaseTableView(_frame: rect, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .white
            $0.separatorColor = .gx_lightGray
            $0.dataSource = self
            $0.delegate = self
            $0.allowsSelection = false
            $0.register(headerFooterViewType: GXCityPickerHeader.self)
            $0.register(cellType: GXActivityPriceTypeCell.self)
            $0.register(cellType: GXActivityTypeCell.self)
        }
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

    required init(frame: CGRect, activityTypeIds: [String], priceType: Int?) {
        super.init(frame: frame)
        self.activityTypeIds = activityTypeIds
        self.priceType = priceType
        self.createSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.bottomLeft, .bottomRight], radius: 16.0)
    }

    func createSubviews() {
        self.backgroundColor = .white
        self.addSubview(self.tableView)
        self.addSubview(self.resetButton)
        self.addSubview(self.confirmButton)
        self.requestListActivityType()
    }

    func requestListActivityType() {
        guard GXActivityManager.shared.activityTypeList.count == 0 else {
            self.updateListActivityData()
            return
        }
        MBProgressHUD.showLoading(to: self)
        GXActivityManager.shared.requestListActivityType{[weak self] in
            MBProgressHUD.dismiss(for: self)
            self?.updateListActivityData()
        } failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self)
            GXToast.showError(error, to: self)
        }
    }

    func updateListActivityData() {
        let allItem = GXPrHomeListActivityTypeItem()
        allItem.activityTypeName = "不限"
        self.activityTypeList = [allItem] + GXActivityManager.shared.activityTypeList
        self.tableView.gx_reloadData()
    }
}

extension GXActivityTypePickerView {
    @objc func resetButtonClicked(_ sender: UIButton) {
        self.activityTypeIds.removeAll()
        self.priceType = nil
        self.tableView.gx_reloadData()
    }

    @objc func confirmButtonClicked(_ sender: UIButton) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GXActivityTypeCell {
            self.activityTypeIds = cell.activityTypeIds
        }
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? GXActivityPriceTypeCell {
            self.priceType = cell.priceType
        }
        self.selectedAction?(self.activityTypeIds, self.priceType)
        self.hide(animated: true)
    }
}

extension GXActivityTypePickerView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: GXActivityTypeCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(list: self.activityTypeList, activityTypeIds: self.activityTypeIds)

            return cell
        }
        else {
            let cell: GXActivityPriceTypeCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(list: GXActivityManager.shared.priceTypeItems, priceType: self.priceType)

            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let column = (self.activityTypeList.count + 2)/3
            if column > 0 {
                return CGFloat(column) * 32.0 + CGFloat(column - 1) * 8.0 + 16.0
            }
            return .zero
        }
        else {
            let column = (GXActivityManager.shared.priceTypeItems.count + 2)/3
            if column > 0 {
                return CGFloat(column) * 32.0 +  CGFloat(column - 1) * 8.0 + 16.0
            }
            return .zero
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(GXCityPickerHeader.self)
        header?.contentView.backgroundColor = .white
        header?.titleLabel.textColor = .gx_black
        if section == 0 {
            header?.titleLabel.text = "活动类型"
        } else {
            header?.titleLabel.text = "活动价格"
        }
        return header
    }

}
