//
//  GXMineStatementVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import PromiseKit
import MBProgressHUD
import GXRefresh

class GXMineStatementVC: GXBaseViewController {
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
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
    private var viewModel: GXMineWalletViewModel!
    
    class func createVC(viewModel: GXMineWalletViewModel?) -> GXMineStatementVC {
        return GXMineStatementVC.xibViewController().then {
            if let viewModel = viewModel {
                $0.viewModel = viewModel
            } else {
                $0.viewModel = GXMineWalletViewModel()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestWalletConsumerDetail()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "My Wallet"
        self.gx_addBackBarButtonItem()
        
        let colors: [UIColor] = [.gx_green, .gx_blue]
        let gradientImage = UIImage(gradientColors: colors, style: .horizontal, size: CGSize(width: 20, height: 10))
        self.topImageView.image = gradientImage
        
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

private extension GXMineStatementVC {
    func requestWalletConsumerDetail() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestWalletConsumerBalance()
        }.then { model in
            self.viewModel.requestWalletConsumerList(isRefresh: true)
        }.done { (model, isLastPage) in
            MBProgressHUD.dismiss()
            self.tableView.reloadData()
            self.tableView.gx_endRefreshing(isNoMore: isLastPage, isSucceed: true)
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
            self.tableView.gx_endRefreshing(isNoMore: false, isSucceed: false)
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

extension GXMineStatementVC: UITableViewDataSource, UITableViewDelegate {
    
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
