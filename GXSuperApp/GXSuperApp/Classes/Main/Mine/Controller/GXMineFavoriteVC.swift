//
//  GXMineFavoriteVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/14.
//

import UIKit
import PromiseKit
import GXRefresh
import MBProgressHUD

class GXMineFavoriteVC: GXBaseViewController {
    @IBOutlet weak var tableView: GXBaseTableView! {
        didSet {
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 12))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
            tableView.backgroundColor = .gx_background
            tableView.sectionHeaderHeight = 12
            tableView.sectionFooterHeight = .leastNormalMagnitude
            tableView.rowHeight = 121.0
            tableView.register(cellType: GXHomeMarkerCell.self)
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    private lazy var viewModel: GXMineFavoriteViewModel = {
        return GXMineFavoriteViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requesFavoriteConsumerList(isShowHUD: true)
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Favorite Stations"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)
        
        self.tableView.gx_header = GXRefreshNormalHeader(completion: { [weak self] in
            self?.requesFavoriteConsumerList(isRefresh: true, completion: { isSucceed, isLastPage in
                self?.tableView.gx_header?.endRefreshing(isNoMore: isLastPage, isSucceed: isSucceed)
            })
        }).then({ header in
            header.updateRefreshTitles()
        })
        self.tableView.gx_footer = GXRefreshNormalFooter(completion: { [weak self] in
            self?.requesFavoriteConsumerList(isRefresh: false, completion: { isSucceed, isLastPage in
                self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
            })
        }).then { footer in
            footer.updateRefreshTitles()
        }
    }
}

private extension GXMineFavoriteVC {
    func requesFavoriteConsumerList(isRefresh: Bool = true, isShowHUD: Bool = false, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHUD {
            MBProgressHUD.showLoading()
        }
        firstly {
            self.viewModel.requesFavoriteConsumerList(isRefresh: isRefresh)
        }.done { (model, isLastPage) in
            if isShowHUD { MBProgressHUD.dismiss() }
            self.tableView.gx_reloadData()
            completion?(true, isLastPage)
        }.catch { error in
            if isShowHUD { MBProgressHUD.dismiss() }
            GXToast.showError(text:error.localizedDescription)
            completion?(false, false)
        }
    }
    
    func requestFavoriteConsumerSaveDelete(indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestFavoriteConsumerSaveDelete(indexPath: indexPath)
        }.done { model in
            MBProgressHUD.dismiss()
            completion(true)
            self.viewModel.list.remove(at: indexPath.section)
            self.tableView.performBatchUpdates {[weak self] in
                self?.tableView.deleteSection(indexPath.section, with: .left)
            }
        }.catch { error in
            MBProgressHUD.dismiss()
            completion(true)
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func showDeleteAlert(indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        GXUtil.showAlert(title: "Are you sure to delete the favorite?", actionTitle: "OK", handler: { alert, index in
            guard index == 1 else { completion(true); return }
            self.requestFavoriteConsumerSaveDelete(indexPath: indexPath, completion: completion)
        })
    }
    
}

extension GXMineFavoriteVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXHomeMarkerCell = tableView.dequeueReusableCell(for: indexPath)
        cell.highlightedEnable = true
        cell.bindCell(model: self.viewModel.list[indexPath.section])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = self.viewModel.list[indexPath.section]
        let vc = GXHomeDetailVC.createVC(stationId: model.stationId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completion) in
            self.showDeleteAlert(indexPath: indexPath, completion: completion)
        })
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}
