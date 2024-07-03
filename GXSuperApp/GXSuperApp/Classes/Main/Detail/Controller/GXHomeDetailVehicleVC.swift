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
    var selectedAction: GXActionBlockItem<GXVehicleConsumerListItem>?
    
    private lazy var viewModel: GXHomeDetailVehicleViewModel = {
        return GXHomeDetailVehicleViewModel()
    }()
    
    class func createVC(vehicleList: [GXVehicleConsumerListItem] = []) -> GXHomeDetailVehicleVC {
        return GXHomeDetailVehicleVC.xibViewController().then {
            $0.viewModel.vehicleList = vehicleList
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.viewModel.vehicleList.count > 0 {
            self.tableView.reloadData()
        } else {
            self.requestVehicleConsumerList()
        }
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Vehicle Management"
        self.gx_addBackBarButtonItem()
        
        self.addButton.setBackgroundColor(.gx_green, for: .normal)
        self.addButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
    }
    
}

private extension GXHomeDetailVehicleVC {
    
    @IBAction func addButtonClicked(_ sender: Any?) {
        let vc = GXHomeDetailAddVehicleVC.xibViewController()
        vc.addCompletion = {[weak self] in
            guard let `self` = self else { return }
            self.requestVehicleConsumerList()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func requestVehicleConsumerList() {
        self.view.showAnimatedGradientSkeleton()
        firstly {
            self.viewModel.requestVehicleConsumerList()
        }.done { model in
            self.view.hideSkeleton()
            self.tableView.reloadData()
        }.catch { error in
            self.view.hideSkeleton()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func requestVehicleConsumerDelete(indexPath: IndexPath) {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestVehicleConsumerDelete(indexPath: indexPath)
        }.done { model in
            MBProgressHUD.dismiss()
            self.tableView.performBatchUpdates {[weak self] in
                self?.tableView.deleteRow(at: indexPath, with: .left)
            }
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
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
        return self.viewModel.vehicleList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXHomeDetailVehicleCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bindCell(model: self.viewModel.vehicleList[indexPath.section])
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.viewModel.vehicleList[indexPath.section]
        self.selectedAction?(model)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completion) in
            GXUtil.showAlert(title: "Are you sure to delete the vehicle?", actionTitle: "OK", handler: { alert, index in
                completion(true)
                guard index == 1 else { return }
                self.requestVehicleConsumerDelete(indexPath: indexPath)
            })
        })
        let model = self.viewModel.vehicleList[indexPath.section]
        let defaultAction = UIContextualAction(style: .normal, title: "Edit", handler: { (action, view, completion) in
            completion(true)
            let vc = GXHomeDetailAddVehicleVC.createVC(vehicle: model)
            vc.addCompletion = {[weak self] in
                guard let `self` = self else { return }
                self.requestVehicleConsumerList()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        })
        defaultAction.backgroundColor = .gx_black
        return UISwipeActionsConfiguration(actions: [deleteAction, defaultAction])
    }
    
}
