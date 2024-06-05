//
//  GXMineSettingNotifiVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit
import GXConfigTableViewVC
import Kingfisher
import MBProgressHUD

class GXMineSettingNotifiVC: GXConfigTableViewController {
    private lazy var navTopView: UIView = {
        return UIView(frame: CGRect(origin: .zero, size: CGSize(width: SCREEN_HEIGHT, height: 44))).then {
            $0.backgroundColor = .white
        }
    }()

    private lazy var viewModel: GXMineSettingNotifiViewModel = {
        return GXMineSettingNotifiViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "消息通知"
        self.view.backgroundColor = .gx_background
        self.addBackBarButtonItem(imageNamed: "l_back")
        self.gx_addNavTopView(color: .white)

        let model = GXConfigTableModel()
        model.style = .insetGrouped
        model.backgroundColor = .gx_background
        let separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        let row0 = GXConfigTableRowSwitchModel()
        row0.separatorInset = separatorInset
        row0.rowHeight = 48.0
        row0.contentMargin = 12.0
        row0.title.accept("用户活动咨询通知")
        row0.titleFont = .gx_font(size: 15)
        row0.titleColor = .gx_black
        row0.onTintColor = .gx_green
        row0.switchAction = {[weak self] isOn in
            self?.viewModel.settingData?.chatConsultateMessage = isOn ? 1:0;
            self?.requestSetMessage(value: isOn, actionFailure: { faiOn in
                row0.isOn.accept(faiOn)
            })
        }

        let row1 = GXConfigTableRowSwitchModel()
        row1.separatorInset = separatorInset
        row1.rowHeight = 48.0
        row1.contentMargin = 12.0
        row1.title.accept("活动群内消息通知")
        row1.titleFont = .gx_font(size: 15)
        row1.titleColor = .gx_black
        row1.onTintColor = .gx_green
        row1.switchAction = {[weak self] isOn in
            self?.viewModel.settingData?.chatGroupMessage = isOn ? 1:0;
            self?.requestSetMessage(value: isOn, actionFailure: { faiOn in
                 row1.isOn.accept(faiOn)
            })
        }

        let row2 = GXConfigTableRowSwitchModel()
        row2.separatorInset = separatorInset
        row2.rowHeight = 48.0
        row2.contentMargin = 12.0
        row2.title.accept("活动问卷通知")
        row2.titleFont = .gx_font(size: 15)
        row2.titleColor = .gx_black
        row2.onTintColor = .gx_green
        row2.switchAction = {[weak self] isOn in
            self?.viewModel.settingData?.questionaireMessage = isOn ? 1:0;
            self?.requestSetMessage(value: isOn, actionFailure: { faiOn in
                row2.isOn.accept(faiOn)
            })
        }

        let row3 = GXConfigTableRowSwitchModel()
        row3.separatorInset = separatorInset
        row3.rowHeight = 48.0
        row3.contentMargin = 12.0
        row3.title.accept("活动得奖通知")
        row3.titleFont = .gx_font(size: 15)
        row3.titleColor = .gx_black
        row3.onTintColor = .gx_green
        row3.switchAction = {[weak self] isOn in
            self?.viewModel.settingData?.bonusMessage = isOn ? 1:0;
            self?.requestSetMessage(value: isOn, actionFailure: { faiOn in
                row3.isOn.accept(faiOn)
            })
        }

        let row4 = GXConfigTableRowSwitchModel()
        row4.separatorInset = separatorInset
        row4.rowHeight = 48.0
        row4.contentMargin = 12.0
        row4.title.accept("工作汇报通知")
        row4.titleFont = .gx_font(size: 15)
        row4.titleColor = .gx_black
        row4.onTintColor = .gx_green
        row4.switchAction = {[weak self] isOn in
            self?.viewModel.settingData?.reportMessage = isOn ? 1:0;
            self?.requestSetMessage(value: isOn, actionFailure: { faiOn in
                row4.isOn.accept(faiOn)
            })
        }

        let section0 = GXConfigTableSectionModel()
        section0.rowList = [row0, row1, row2, row3, row4]
        model.sectionList = [section0]
        self.dataSource = model

        self.tableView?.separatorColor = .gx_lightGray
        self.tableView?.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.tableView?.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 16))
        self.tableView?.snp.makeConstraints({ make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        })

        self.requestGetMessageSetting()
    }

    func updateDataSource() {
        guard let data = self.viewModel.settingData else { return }
        guard let section = self.dataSource?.sectionList.first else { return }

        if let row0 = section.rowList[0] as? GXConfigTableRowSwitchModel {
            row0.isOn.accept(data.chatConsultateMessage == 1)
        }
        if let row1 = section.rowList[1] as? GXConfigTableRowSwitchModel {
            row1.isOn.accept(data.chatGroupMessage == 1)
        }
        if let row2 = section.rowList[2] as? GXConfigTableRowSwitchModel {
            row2.isOn.accept(data.questionaireMessage == 1)
        }
        if let row3 = section.rowList[3] as? GXConfigTableRowSwitchModel {
            row3.isOn.accept(data.bonusMessage == 1)
        }
        if let row4 = section.rowList[4] as? GXConfigTableRowSwitchModel {
            row4.isOn.accept(data.reportMessage == 1)
        }
    }

    public func gx_addNavTopView(color: UIColor) {
        self.navTopView.backgroundColor = color
        self.view.addSubview(self.navTopView)
        self.navTopView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
    }
}

extension GXMineSettingNotifiVC {
    func requestGetMessageSetting() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetMessageSetting(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.updateDataSource()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestSetMessage(value: Bool, actionFailure: GXActionBlockItem<Bool>?) {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestSetMessageSetting(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
            actionFailure?(!value)
        })
    }

}
