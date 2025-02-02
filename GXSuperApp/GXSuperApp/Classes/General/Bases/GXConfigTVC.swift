//
//  GXConfigTVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/29.
//

import UIKit
import GXConfigTableViewVC

class GXConfigTVC: GXBaseViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    var dataSource: GXConfigTableModel? {
        didSet {
            self.tableView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.configuration()
    }
    
    override func setupViewController() {}

    open func gx_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, model: GXConfigTableRowCustomModel) -> UITableViewCell  {
        return UITableViewCell()
    }
}

extension GXConfigTVC: UITableViewDataSource, UITableViewDelegate {
    // MARK - UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource?.sectionList.count ?? 0
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.sectionList[section].rowList.count ?? 0
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.dataSource?.sectionList[indexPath.section].rowList[indexPath.row]

        if let inputModel = model as? GXConfigTableRowInputModel {
            var cell = tableView.dequeueReusableCell(withIdentifier: inputModel.reuseIdentifier) as? GXConfigTableRowInputCell
            if cell == nil {
                cell = GXConfigTableRowInputCell(style: inputModel.style, reuseIdentifier: inputModel.reuseIdentifier)
            }
            cell?.bind(model: inputModel)

            return cell!
        }
        else if let switchModel = model as? GXConfigTableRowSwitchModel {
            var cell = tableView.dequeueReusableCell(withIdentifier: switchModel.reuseIdentifier) as? GXConfigTableRowSwitchCell
            if cell == nil {
                cell = GXConfigTableRowSwitchCell(style: switchModel.style, reuseIdentifier: switchModel.reuseIdentifier)
            }
            cell?.bind(model: switchModel)

            return cell!
        }
        else if let avatarModel = model as? GXConfigTableRowAvatarModel {
            var cell = tableView.dequeueReusableCell(withIdentifier: avatarModel.reuseIdentifier) as? GXConfigTableRowAvatarCell
            if cell == nil {
                cell = GXConfigTableRowAvatarCell(style: avatarModel.style, reuseIdentifier: avatarModel.reuseIdentifier)
            }
            cell?.bind(model: avatarModel)

            return cell!
        }
        else if let buttonModel = model as? GXConfigTableRowButtonModel {
            var cell = tableView.dequeueReusableCell(withIdentifier: buttonModel.reuseIdentifier) as? GXConfigTableRowButtonCell
            if cell == nil {
                cell = GXConfigTableRowButtonCell(style: buttonModel.style, reuseIdentifier: buttonModel.reuseIdentifier)
            }
            cell?.bind(model: buttonModel)

            return cell!
        }
        else if let customModel = model as? GXConfigTableRowCustomModel {
            let cell = self.gx_tableView(tableView, cellForRowAt: indexPath, model: customModel)
            return cell
        }
        else if let defaultModel = model {
            var cell = tableView.dequeueReusableCell(withIdentifier: defaultModel.reuseIdentifier) as? GXConfigTableRowDefaultCell
            if cell == nil {
                cell = GXConfigTableRowDefaultCell(style: defaultModel.style, reuseIdentifier: defaultModel.reuseIdentifier)
            }
            cell?.bind(model: defaultModel)

            return cell!
        }
        return UITableViewCell()
    }
    // MRAK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = self.dataSource?.sectionList[section].header else { return nil }
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: header.reuseIdentifier) as? GXConfigTableHeaderFooter
        if view == nil {
            view = GXConfigTableHeaderFooter(reuseIdentifier: header.reuseIdentifier)
        }
        view?.bind(model: header)
        return view
    }
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = self.dataSource?.sectionList[section].footer else { return nil }
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: footer.reuseIdentifier) as? GXConfigTableHeaderFooter
        if view == nil {
            view = GXConfigTableHeaderFooter(reuseIdentifier: footer.reuseIdentifier)
        }
        view?.bind(model: footer)
        return view
    }
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return .zero
    }
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return .zero
    }
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return .zero
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.dataSource?.sectionList[section].header?.height ?? .leastNonzeroMagnitude
    }
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.dataSource?.sectionList[section].footer?.height ?? .leastNonzeroMagnitude
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.dataSource?.sectionList[indexPath.section].rowList[indexPath.row].rowHeight ?? .leastNonzeroMagnitude
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dataSource?.sectionList[indexPath.section].rowList[indexPath.row].action?()
    }
}

