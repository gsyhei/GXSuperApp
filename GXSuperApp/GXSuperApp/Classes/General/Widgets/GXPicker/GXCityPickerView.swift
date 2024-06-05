//
//  GXCityPickerView.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/26.
//

import UIKit
import MBProgressHUD

class GXCityPickerView: UIView {
    var selectedAction: GXActionBlockItem<String>?
    var selectedCity: String = ""

    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .white
            $0.separatorColor = .gx_lightGray
            $0.rowHeight = 40.0
            $0.dataSource = self
            $0.delegate = self
            $0.register(headerFooterViewType: GXCityPickerHeader.self)
            $0.register(cellType: GXCityPickerCell.self)
            $0.register(cellType: GXSelectItemCell.self)
        }
    }()

    required init(frame: CGRect, selectedCity: String) {
        super.init(frame: frame)
        self.selectedCity = selectedCity
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
        self.tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        self.requestListCity()
    }

    func requestListCity() {
        guard GXActivityManager.shared.cityList.count == 0 else {
            self.tableView.gx_reloadData()
            return
        }
        MBProgressHUD.showLoading(to: self)
        GXActivityManager.shared.requestListCity {[weak self] in
            MBProgressHUD.dismiss(for: self)
            self?.tableView.gx_reloadData()
        } failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self)
            GXToast.showError(error, to: self)
        }
    }
}

extension GXCityPickerView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return GXActivityManager.shared.cityList.count + 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return GXActivityManager.shared.cityList[section - 1].list.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: GXCityPickerCell = tableView.dequeueReusableCell(for: indexPath)
            let city = GXCityItem()
            city.cityName = GXLocationManager.shared.cityName ?? GXUserManager.shared.city
            cell.bindCell(list: [city], selectedCity: city.cityName)
            cell.selectedAction = {[weak self] item in
                self?.selectedAction?(item.cityName)
                self?.hide(animated: true)
            }

            return cell
        }
        else {
            let cell: GXSelectItemCell = tableView.dequeueReusableCell(for: indexPath)
            let model = GXActivityManager.shared.cityList[indexPath.section - 1].list[indexPath.row]
            cell.textLabel?.text = model.cityName

            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(GXCityPickerHeader.self)
        if section == 0 {
            header?.contentView.backgroundColor = .white
            header?.titleLabel.textColor = .gx_gray
            header?.titleLabel.text = "当前定位城市"
        }
        else {
            header?.contentView.backgroundColor = .gx_background
            let model = GXActivityManager.shared.cityList[section - 1]
            header?.titleLabel.textColor = .gx_black
            header?.titleLabel.text = model.cityPinYin
        }
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 48.0
        }
        else {
            return 44.0
        }
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return [""] + GXActivityManager.shared.cityListTitles
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cityName = GXLocationManager.shared.cityName ?? GXUserManager.shared.city
            self.selectedAction?(cityName)
        }
        else {
            let model = GXActivityManager.shared.cityList[indexPath.section - 1].list[indexPath.row]
            self.selectedAction?(model.cityName)
            GXUserManager.updateLocation(nil)
        }
        self.hide(animated: true)
    }

}
