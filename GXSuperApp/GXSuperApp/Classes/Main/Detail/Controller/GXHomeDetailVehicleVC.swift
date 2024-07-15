//
//  GXHomeDetailVehicleMVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/29.
//

import UIKit
import SkeletonView
import PromiseKit
import MBProgressHUD
import GXRefresh

class GXHomeDetailVehicleVC: GXBaseViewController {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(estimated: true)
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            tableView.sectionHeaderHeight = 12.0
            tableView.sectionFooterHeight = .leastNormalMagnitude
            tableView.rowHeight = 120
            tableView.register(cellType: GXHomeDetailVehicleCell.self)
        }
    }
    var selectedAction: GXActionBlock?
    
    private lazy var viewModel: GXHomeDetailVehicleViewModel = {
        return GXHomeDetailVehicleViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if GXUserManager.shared.vehicleList.count > 0 {
            self.tableView.reloadData()
        } else {
            self.requestVehicleConsumerList()
        }
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Vehicle Management"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)
        
        self.addButton.setBackgroundColor(.gx_green, for: .normal)
        self.addButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        
        self.tableView.gx_header = GXRefreshNormalHeader(completion: { [weak self] in
            guard let `self` = self else { return }
            self.requestVehicleConsumerList(isShowHud: false)
        }).then { footer in
            footer.updateRefreshTitles()
        }
    }
    
}

private extension GXHomeDetailVehicleVC {
    
    @IBAction func addButtonClicked(_ sender: Any?) {
        self.pushAddVehicleVC(vehicle: nil)
    }
    
    func requestVehicleConsumerList(isShowHud: Bool = true) {
        if isShowHud { self.view.showAnimatedGradientSkeleton() }
        firstly {
            self.viewModel.requestVehicleConsumerList()
        }.done { model in
            if isShowHud { 
                self.view.hideSkeleton()
            } else {
                self.view.hideSkeleton()
                self.tableView.gx_header?.endRefreshing(isSucceed: true)
            }
            self.tableView.reloadData()
        }.catch { error in
            self.view.hideSkeleton()
            if isShowHud {
                GXToast.showError(text:error.localizedDescription)
            } else {
                self.tableView.gx_header?.endRefreshing(isSucceed: false, text: error.localizedDescription)
            }
        }
    }
    
    func requestVehicleConsumerDelete(indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestVehicleConsumerDelete(indexPath: indexPath)
        }.done { model in
            MBProgressHUD.dismiss()
            completion(true)
            GXUserManager.shared.vehicleList.remove(at: indexPath.section)
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
        GXUtil.showAlert(title: "Are you sure to delete the vehicle?", actionTitle: "OK", handler: { alert, index in
            guard index == 1 else { completion(true); return }
            self.requestVehicleConsumerDelete(indexPath: indexPath, completion: completion)
        })
    }
    
    func pushAddVehicleVC(vehicle: GXVehicleConsumerListItem?) {
        let vc = GXHomeDetailAddVehicleVC.createVC(vehicle: vehicle)
        vc.addCompletion = {[weak self] in
            guard let `self` = self else { return }
            self.requestVehicleConsumerList()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension GXHomeDetailVehicleVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    // MARK: - SkeletonTableViewDataSource
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return GXHomeDetailVehicleCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        let cell: GXHomeDetailVehicleCell = skeletonView.dequeueReusableCell(for: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return GXUserManager.shared.vehicleList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXHomeDetailVehicleCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bindCell(model: GXUserManager.shared.vehicleList[indexPath.section])
        cell.deleteAction = {[weak self] curCell in
            guard let `self` = self else { return }
            guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
            self.showDeleteAlert(indexPath: curIndexPath) { _ in }
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let selectedAction = selectedAction else { return }
        let model = GXUserManager.shared.vehicleList[indexPath.section]
        GXUserManager.shared.selectedVehicle = model
        selectedAction()
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completion) in
            self.showDeleteAlert(indexPath: indexPath, completion: completion)
        })
        let model = GXUserManager.shared.vehicleList[indexPath.section]
        let defaultAction = UIContextualAction(style: .normal, title: "Edit", handler: { (action, view, completion) in
            completion(true)
            self.pushAddVehicleVC(vehicle: model)
        })
        defaultAction.backgroundColor = .gx_black
        return UISwipeActionsConfiguration(actions: [deleteAction, defaultAction])
    }
    
}
