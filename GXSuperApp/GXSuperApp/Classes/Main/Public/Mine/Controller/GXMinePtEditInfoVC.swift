//
//  GXMinePtEditInfoVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/29.
//

import UIKit
import GXConfigTableViewVC
import RxCocoa
import RxCocoaPlus
import MBProgressHUD

class GXMinePtEditInfoVC: GXConfigTVC {
    @IBOutlet weak var saveButton: UIButton!

    var completion: GXActionBlockItem<UIViewController?>?

    private lazy var viewModel: GXMinePtEditInfoViewModel = {
        return GXMinePtEditInfoViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "个人信息"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)
        self.saveButton.setBackgroundColor(.gx_green, for: .normal)
        self.tableView.separatorColor = .gx_lightGray
        self.tableView.register(cellType: GXMinePtEditInfoCell.self)
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.reloadTableViewData()
    }

    func reloadTableViewData() {
        let model = GXConfigTableModel()
        let section0 = GXConfigTableSectionModel()
        
        let row0 = GXConfigTableRowDefaultModel()
        row0.rowHeight = 50.0
        row0.contentMargin = 0.0
        row0.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        row0.title.accept("昵称")
        row0.titleColor = .gx_black
        row0.titleFont = .gx_font(size: 16)
        row0.detail.accept(GXUserManager.shared.user?.nickName ?? "填写昵称")
        row0.detailFont = .gx_font(size: 16)
        row0.detailColor = .gx_drakGray
        row0.action = {[weak self] in
            guard let `self` = self else { return }
            let vc = GXMinePtEditNicknameVC.xibViewController()
            vc.viewModel = self.viewModel
            vc.completion = {[weak self] in
                self?.tableView.reloadData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.viewModel.nicknameModel = row0

        let row1 = GXConfigTableRowDefaultModel()
        row1.rowHeight = 50.0
        row1.contentMargin = 0.0
        row1.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        row1.title.accept("性别")
        row1.titleColor = .gx_black
        row1.titleFont = .gx_font(size: 16)
        var userMale: String = "选择性别"
        if GXUserManager.shared.user?.userMale == 1 {
            userMale = "男"
        } else if GXUserManager.shared.user?.userMale == 2 {
            userMale = "女"
        }
        row1.detail.accept(userMale)
        row1.detailFont = .gx_font(size: 16)
        row1.detailColor = .gx_drakGray
        row1.action = { [weak self] in
            guard let `self` = self else { return }
            let vc = GXMineEditUserMaleVC.xibViewController()
            vc.viewModel = self.viewModel
            vc.completion = {[weak self] in
                self?.tableView.reloadData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.viewModel.userMaleModel = row1

        let row2 = GXConfigTableRowDefaultModel()
        row2.rowHeight = 50.0
        row2.contentMargin = 0.0
        row2.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        row2.title.accept("生日")
        row2.titleColor = .gx_black
        row2.detail.accept("选择生日")
        row2.titleFont = .gx_font(size: 16)
        row2.detailFont = .gx_font(size: 16)
        row2.detailColor = .gx_drakGray
        if let birthday = GXUserManager.shared.user?.birthday, birthday.count > 0 {
            if let date = Date.date(dateString: birthday, format: "yyyyMMdd") {
                row2.detail.accept(date.string(format: "yyyy年MM月dd日"))
            }
        }
        row2.action = {[weak self] in
            guard let `self` = self else { return }
            let pickerDateView: GXDate1PickerView = {[weak self] in
                return GXDate1PickerView.xibView().then {
                    $0.frame = CGRect(x: 0, y: 0, width: SCREEN_HEIGHT, height: 340)
                    $0.titleLabel.text = "请选择您的生日"
                    $0.datePicker.maximumDate = Date()
                    if let birthday = self?.viewModel.birthdayModel?.detail.value {
                        if let date = Date.date(dateString: birthday, format: "yyyy年MM月dd日") {
                            $0.datePicker.date = date
                        }
                    }
                    else {
                        if let date = Date.date(dateString: "19900101", format: "yyyyMMdd") {
                            $0.datePicker.date = date
                        }
                    }
                    $0.completion = { date in
                        row2.detail.accept(date.string(format: "yyyy年MM月dd日"))
                    }
                }
            }()
            pickerDateView.show(to: self.view, style: .sheetBottom, usingSpring: true)
        }
        self.viewModel.birthdayModel = row2

        let row3 = GXConfigTableRowCustomModel()
        row3.rowHeight = 300.0
        row3.title.accept("个人介绍")
        row3.detail.accept(GXUserManager.shared.user?.personalIntroduction)
        row3.action = {[weak self] in
            guard let `self` = self else { return }
            let vc = GXMinePtEditPersonalVC.xibViewController()
            vc.viewModel = self.viewModel
            vc.completion = {[weak self] in
                self?.tableView.reloadData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.viewModel.personalModel = row3
        
        section0.rowList = [row0, row1, row2, row3]
        model.sectionList = [section0]
        self.dataSource = model
    }

    override func gx_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, model: GXConfigTableRowCustomModel) -> UITableViewCell {
        let cell: GXMinePtEditInfoCell = tableView.dequeueReusableCell(for: indexPath)
        cell.infoLabel.text = self.viewModel.personalModel?.detail.value ?? "编辑个人介绍"
        return cell
    }
    public override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.dataSource?.sectionList[indexPath.section].rowList[indexPath.row]
        return model?.rowHeight ?? 0
    }
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.dataSource?.sectionList[indexPath.section].rowList[indexPath.row]
        if model is GXConfigTableRowCustomModel {
            return UITableView.automaticDimension
        }
        return model?.rowHeight ?? .leastNonzeroMagnitude
    }
}

extension GXMinePtEditInfoVC {
    func requestEditUserInfo() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestEditUserInfo {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showSuccess(text: "保存成功")
            self.completion?(self)
        } failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        }
    }
}

extension GXMinePtEditInfoVC {
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.viewModel.nicknameModel?.detail.value?.count ?? 0 == 0 {
            GXToast.showSuccess(text: "请输入昵称", to: self.view)
            return
        }
        self.requestEditUserInfo()
    }
}
