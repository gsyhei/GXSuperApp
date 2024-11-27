//
//  GXMineWalletVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import PromiseKit
import MBProgressHUD
import GXRefresh

class GXMineWalletVC: GXBaseViewController {
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    //@IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var withdrawButton: UIButton!
    @IBOutlet weak var rechargeButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration()
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.sectionHeaderHeight = .leastNormalMagnitude
            tableView.sectionFooterHeight = 10
            tableView.rowHeight = 40
            tableView.register(cellType: GXMineStatementCell.self)
        }
    }
    
    private lazy var viewModel: GXMineWalletViewModel = {
        return GXMineWalletViewModel()
    }()
    
    class func createVC(balanceData: GXWalletConsumerBalanceData?) -> GXMineWalletVC {
        return GXMineWalletVC.xibViewController().then {
            $0.viewModel.balanceData = balanceData
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.detailButton.imageLocationAdjust(model: .right, spacing: 5.0)
//    }
    
    override func viewDidAppearForAfterLoading() {
        self.requestWalletConsumerBalance(isShowHud: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestWalletConsumerBalance()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "My Wallet"
        self.gx_addBackBarButtonItem()
        
        let colors: [UIColor] = [.gx_green, .gx_blue]
        let gradientImage = UIImage(gradientColors: colors, style: .obliqueDown, size: CGSize(width: 20, height: 10))
        self.topImageView.image = gradientImage

        self.withdrawButton.layer.borderWidth = 1.0
        self.withdrawButton.layer.borderColor = UIColor.gx_green.cgColor
        self.withdrawButton.setBackgroundColor(.white, for: .normal)
        self.withdrawButton.setBackgroundColor(.gx_background, for: .highlighted)
        
        self.rechargeButton.setBackgroundColor(.gx_green, for: .normal)
        self.rechargeButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        
        self.tableView.gx_header = GXRefreshNormalHeader(completion: { [weak self] in
            self?.requestWalletConsumerList(isRefresh: true)
        }).then({ header in
            header.updateRefreshTitles()
        })
        self.tableView.gx_footer = GXRefreshNormalFooter(completion: { [weak self] in
            self?.requestWalletConsumerList(isRefresh: false)
        }).then { footer in
            footer.updateRefreshTitles()
        }
        self.updateDataSource()
    }
}

private extension GXMineWalletVC {
    func requestWalletConsumerBalance(isShowHud: Bool = true) {
        if isShowHud {
            MBProgressHUD.showLoading()
        }
        self.requestWalletConsumerList()
        firstly {
            self.viewModel.requestWalletConsumerBalance()
        }.done { model in
            MBProgressHUD.dismiss()
            self.updateDataSource()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func requestWalletConsumerList(isRefresh: Bool = true) {
        firstly {
            self.viewModel.requestWalletConsumerList(isRefresh: isRefresh)
        }.done { (model, isLastPage) in
            self.tableView.reloadData()
            self.tableView.gx_endRefreshing(isNoMore: isLastPage, isSucceed: true)
        }.catch { error in
            GXToast.showError(text:error.localizedDescription)
            self.tableView.gx_endRefreshing(isNoMore: false, isSucceed: false)
        }
    }
    
    func updateDataSource() {
        self.tableView.reloadData()
        self.balanceLabel.text = String(format: "$ %.2f", self.viewModel.balanceData?.available ?? 0)
    }
}

extension GXMineWalletVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.list.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXMineStatementCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bindCell(model: self.viewModel.list[indexPath.section])
        return cell
    }
}

private extension GXMineWalletVC {
//    @IBAction func detailButtonClicked(_ sender: UIButton) {
//        let vc = GXMineStatementVC.createVC(viewModel: self.viewModel)
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
    @IBAction func withdrawButtonClicked(_ sender: UIButton) {
        let vc = GXMineWithdrawVC.xibViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func rechargeButtonClicked(_ sender: UIButton) {
        let vc = GXMineRechargeVC.xibViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
