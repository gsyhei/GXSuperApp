//
//  GXMinePrOrderDetailVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/17.
//

import UIKit
import MBProgressHUD

class GXMinePrOrderDetailVC: GXBaseViewController {
    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
            $0.backgroundColor = .white
            $0.allowsSelection = false
            $0.separatorStyle = .none
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXPrCalendarActivityPageCell.self)
            $0.register(cellType: GXMinePrOrderDetailCell.self)
        }
    }()

    private lazy var viewModel: GXMinePrOrderDetailViewModel = {
        return GXMinePrOrderDetailViewModel()
    }()

    init(orderSn: String) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel.orderSn = orderSn
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetSelectByOrderSn()
    }

    override func setupViewController() {
        self.title = "订单详情"
        self.view.backgroundColor = .white
        self.gx_addBackBarButtonItem()

        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension GXMinePrOrderDetailVC {
    func requestGetSelectByOrderSn() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetSelectByOrderSn(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.reloadData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXMinePrOrderDetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: GXPrCalendarActivityPageCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.data)
            return cell
        }
        else {
            let cell: GXMinePrOrderDetailCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.data)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return .zero
        }
        else {
            return 300.0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 130.0
        }
        else {        
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
