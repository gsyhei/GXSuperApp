//
//  GXMineEditUserMaleVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/2/3.
//

import UIKit
import MBProgressHUD

class GXMineEditUserMaleVC: GXBaseViewController {
    @IBOutlet weak var tableView: GXBaseTableView!
    /// 提交按钮
    @IBOutlet weak var submitButton: UIButton!
    
    weak var viewModel: GXMinePtEditInfoViewModel!
    var completion: GXActionBlock?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "设置性别"
        self.gx_addNavTopView(color: .white)
        self.gx_addBackBarButtonItem()
        self.submitButton.setBackgroundColor(.gx_green, for: .normal)

        self.tableView.rowHeight = 50.0
        self.tableView.separatorColor = .gx_lightGray
        self.tableView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 1))
        self.tableView.register(cellType: GXSelectItemCell.self)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()
        self.view.layoutIfNeeded()

        var index: Int = 0
        if let userMaleName = self.viewModel.userMaleModel?.detail.value {
            if userMaleName == "男" {
                index = 0
            } else if userMaleName == "女" {
                index = 1
            } else {
                self.viewModel.userMaleModel?.detail.accept("男")
                index = 0
            }
        }
        else {
            self.viewModel.userMaleModel?.detail.accept("男")
        }
        self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
    }

    func requestEditUserInfo() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestEditUserInfo {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showSuccess(text: "保存成功")
            self.navigationController?.popViewController(animated: true)
            self.completion?()
        } failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        }
    }
}

extension GXMineEditUserMaleVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXSelectItemCell = tableView.dequeueReusableCell(for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "男"
        }
        else {
            cell.textLabel?.text = "女"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.viewModel.userMaleModel?.detail.accept("男")
        }
        else {
            self.viewModel.userMaleModel?.detail.accept("女")
        }
    }

}

extension GXMineEditUserMaleVC {
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        self.requestEditUserInfo()
    }
}
