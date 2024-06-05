//
//  GXPtCalendarCityVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/28.
//

import UIKit
import MBProgressHUD

class GXParticipantHomeCityVC: GXBaseTableViewController {
    var selectedAction: GXActionBlockItem<String>?
    var selectedCity: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestListCity()
    }

    override func setupViewController() {
        self.title = "城市"
        self.gx_addBackBarButtonItem()

        self.tableView.configuration()
        self.tableView.separatorColor = .gx_lightGray
        self.tableView.register(headerFooterViewType: GXCityPickerHeader.self)
        self.tableView.register(cellType: GXCityPickerCell.self)
        self.tableView.register(cellType: GXSelectItemCell.self)
    }

    func requestListCity() {
        if GXActivityManager.shared.cityList.count > 0 && GXActivityManager.shared.hotCityList.count > 0 {
            self.tableView.reloadData()
            return
        }
        MBProgressHUD.showLoading()
        let group = DispatchGroup()
        if GXActivityManager.shared.cityList.count == 0 {
            group.enter()
            GXActivityManager.shared.requestListCity(success: {
                group.leave()
            }) { error in
                GXToast.showError(error)
                group.leave()
            }
        }
        if GXActivityManager.shared.hotCityList.count == 0 {
            group.enter()
            GXActivityManager.shared.requestListHotCity(success: {
                group.leave()
            }) { error in
                GXToast.showError(error)
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            MBProgressHUD.dismiss()
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return GXActivityManager.shared.cityList.count + 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 1
        }
        else {
            return GXActivityManager.shared.cityList[section - 2].list.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: GXCityPickerCell = tableView.dequeueReusableCell(for: indexPath)
            let city = GXCityItem()
            city.cityName = GXLocationManager.shared.cityName ?? GXUserManager.shared.city
            cell.bindCell(list: [city], selectedCity: city.cityName)
            cell.selectedAction = {[weak self] item in
                self?.selectedAction?(item.cityName)
                self?.backBarButtonItemTapped()
            }
            return cell
        }
        else if indexPath.section == 1 {
            let cell: GXCityPickerCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(list: GXActivityManager.shared.hotCityList, selectedCity: self.selectedCity)
            cell.selectedAction = {[weak self] item in
                self?.selectedAction?(item.cityName)
                self?.backBarButtonItemTapped()
            }
            return cell
        }
        else {
            let cell: GXSelectItemCell = tableView.dequeueReusableCell(for: indexPath)
            let model = GXActivityManager.shared.cityList[indexPath.section - 2].list[indexPath.row]
            cell.textLabel?.text = model.cityName

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(GXCityPickerHeader.self)
        if section == 0 {
            header?.contentView.backgroundColor = .white
            header?.titleLabel.textColor = .gx_gray
            header?.titleLabel.text = "当前定位城市"
        }
        else if section == 1 {
            header?.contentView.backgroundColor = .white
            header?.titleLabel.textColor = .gx_gray
            header?.titleLabel.text = "热门城市"
        }
        else {
            header?.contentView.backgroundColor = .gx_background
            let model = GXActivityManager.shared.cityList[section - 2]
            header?.titleLabel.textColor = .gx_black
            header?.titleLabel.text = model.cityPinYin
        }
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 48.0
        }
        else if indexPath.section == 1 {
            let column = (GXActivityManager.shared.hotCityList.count + 2)/3
            if column > 0 {
                return CGFloat(column) * 32.0 + CGFloat(column - 1) * 8.0 + 16.0
            }
            return .zero
        }
        else {
            return 44.0
        }
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return ["", "热"] + GXActivityManager.shared.cityListTitles
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cityName = GXLocationManager.shared.cityName ?? GXUserManager.shared.city
            self.selectedAction?(cityName)
        }
        else if indexPath.section == 1 {
            let model = GXActivityManager.shared.hotCityList[indexPath.row]
            self.selectedAction?(model.cityName)
            GXUserManager.updateLocation(nil)
        }
        else {
            let model = GXActivityManager.shared.cityList[indexPath.section - 2].list[indexPath.row]
            self.selectedAction?(model.cityName)
            GXUserManager.updateLocation(nil)
        }
        self.backBarButtonItemTapped()
    }

}
