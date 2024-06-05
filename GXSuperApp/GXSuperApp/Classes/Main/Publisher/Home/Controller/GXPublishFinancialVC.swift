//
//  GXPublishFinancialVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/23.
//

import UIKit
import MBProgressHUD
import GXRefresh

class GXPublishFinancialVC: GXBaseViewController {
    @IBOutlet weak var tableView: GXBaseTableView!
    @IBOutlet weak var signUpIncomeButton: UIButton!
    @IBOutlet weak var signUpIncomeLabel: UILabel!
    @IBOutlet weak var suppliesCostLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!

    private lazy var addButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.contentHorizontalAlignment = .right
            $0.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 44))
            $0.setTitle("添加物料", for: .normal)
            $0.setTitleColor(.gx_black, for: .normal)
            $0.setTitleColor(.gx_lightGray, for: .highlighted)
            $0.titleLabel?.font = .gx_font(size: 15)
            $0.setImage(UIImage(named: "aw_add"), for: .normal)
            $0.addTarget(self, action: #selector(self.rightButtonItemTapped), for: .touchUpInside)
        }
    }()

    private lazy var viewModel: GXPublishFinancialViewModel = {
        return GXPublishFinancialViewModel()
    }()

    class func createVC(activityData: GXActivityBaseInfoData) -> GXPublishFinancialVC {
        return GXPublishFinancialVC.xibViewController().then {
            $0.viewModel.activityData = activityData
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.signUpIncomeButton.imageLocationAdjust(model: .right, spacing: 2.0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.requestRefreshData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "财务"
        self.gx_addBackBarButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.addButton)

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.placeholder = "暂无物料"
        self.tableView.setAddButton(title: "添加物料", type: 0) {[weak self] in
            guard let `self` = self else { return }
            let vc = GXPublishFinancialEditMaterialVC.createVC(activityData: self.viewModel.activityData)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.tableView.register(cellType: GXPublishFinancialCell.self)

        self.tableView.gx_header = GXRefreshNormalHeader(completion: { [weak self] in
            self?.requestData(isRefresh: true, isShowHud: false, completion: { isSucceed, isLastPage in
                self?.tableView.gx_header?.endRefreshing(isNoMore: isLastPage, isSucceed: isSucceed)
            })
        }).then({ header in
            header.updateRefreshTitles()
        })
        self.tableView.gx_footer = GXRefreshNormalFooter(completion: { [weak self] in
            self?.requestData(isRefresh: false, isShowHud: false, completion: { isSucceed, isLastPage in
                self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
            })
        }).then { footer in
            footer.updateRefreshTitles()
        }
    }

    func updateTopView() {
        self.signUpIncomeLabel.text = String(format: "%.2f", self.viewModel.infoData?.signBalance ?? 0)
        self.suppliesCostLabel.text = String(format: "%.2f", self.viewModel.infoData?.materialBalance ?? 0)
        self.profitLabel.text = String(format: "%.2f", self.viewModel.infoData?.profitBalance ?? 0)
    }
}

extension GXPublishFinancialVC {
    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetActivityFinanceInfo(refresh: isRefresh, success: {[weak self] isLastPage in
            MBProgressHUD.dismiss(for: self?.view)
            self?.updateTopView()
            self?.tableView.gx_reloadData()
            completion?(true, isLastPage)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
            completion?(false, false)
        })
    }

    func requestRefreshData() {
        self.requestData(isRefresh: true, isShowHud: true) { [weak self] isSucceed, isLastPage in
            self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
        }
    }

    func requestDeleteFinance(indexPath: IndexPath) {
        let model = self.viewModel.list[indexPath.row]

        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestDeleteFinance(financeId: model.id, success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.viewModel.list.remove(at: indexPath.row)
            self.tableView.updateWithBlock { tabView in
                tabView?.deleteRow(at: indexPath, with: .left)
            } completion: {[weak self] finished in
                self?.tableView.gx_reloadData()
                self?.requestRefreshData()
            }
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXPublishFinancialVC {

    @objc func rightButtonItemTapped() {
        let vc = GXPublishFinancialEditMaterialVC.createVC(activityData: self.viewModel.activityData)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func signUpIncomeButtonClicked(_ sender: UIButton) {
        let vc = GXPublishMemberVC.createVC(activityData: self.viewModel.activityData, selectIndex: 1)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension GXPublishFinancialVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPublishFinancialCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.list[indexPath.row]
        cell.bindCell(model: model)

        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil, handler: { (action, view, completion) in
            GXUtil.showAlert(title: "确定删除当前物料吗？", actionTitle: "确定") { alert, index in
                completion(true)
                guard index == 1 else { return }
                self.requestDeleteFinance(indexPath: indexPath)
            }
        })
        let deleteLabel = UILabel()
        deleteLabel.text = "删除"
        deleteLabel.textColor = .white
        deleteLabel.font = .gx_font(size: 17)
        deleteLabel.sizeToFit()
        deleteAction.image = UIImage.gx_createImage(view: deleteLabel)
        let editAction = UIContextualAction(style: .normal, title: nil, handler: { (action, view, completion) in
            let model = self.viewModel.list[indexPath.row]
            let vc = GXPublishFinancialEditMaterialVC.createVC(activityData: self.viewModel.activityData, data: model)
            self.navigationController?.pushViewController(vc, animated: true)
            completion(true)
        })
        let editLabel = UILabel()
        editLabel.text = "编辑"
        editLabel.textColor = .gx_black
        editLabel.font = .gx_font(size: 17)
        editLabel.sizeToFit()
        editAction.image = UIImage.gx_createImage(view: editLabel)
        editAction.backgroundColor = .gx_green
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = self.viewModel.list[indexPath.row]
        let vc = GXPublishFinancialEditMaterialVC.createVC(activityData: self.viewModel.activityData, data: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
