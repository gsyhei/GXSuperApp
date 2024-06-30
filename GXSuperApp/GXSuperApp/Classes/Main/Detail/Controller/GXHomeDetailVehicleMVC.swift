//
//  GXHomeDetailVehicleMVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/29.
//

import UIKit
import SkeletonView

class GXHomeDetailVehicleMVC: GXBaseViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestVehicle()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Vehicle Management"
        self.gx_addBackBarButtonItem()
        
        self.addButton.setBackgroundColor(.gx_green, for: .normal)
        self.addButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        
    }
    
    @IBAction func addButtonClicked(_ sender: Any?) {
        
    }
    
    func requestVehicle() {
        self.view.showAnimatedGradientSkeleton()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.view.hideSkeleton()
        })
    }
}

extension GXHomeDetailVehicleMVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXHomeDetailVehicleCell = tableView.dequeueReusableCell(for: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        tableView.deselectRow(at: indexPath, animated: true)
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completion) in
            GXUtil.showAlert(title: "Are you sure to delete the vehicle?", actionTitle: "OK", handler: { alert, index in
                completion(true)
                guard index == 1 else { return }
                
            })
        })
        let defaultAction = UIContextualAction(style: .normal, title: "Edit", handler: { (action, view, completion) in
            completion(true)
            
        })
        defaultAction.backgroundColor = .gx_black
        return UISwipeActionsConfiguration(actions: [deleteAction, defaultAction])
    }
    
}
