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
            tableView.sectionHeaderHeight = 0
            tableView.sectionFooterHeight = 0
            tableView.estimatedRowHeight = 132
            tableView.rowHeight = 132
            tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
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
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return GXHomeDetailVehicleCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        let cell: GXHomeDetailVehicleCell = skeletonView.dequeueReusableCell(for: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXHomeDetailVehicleCell = tableView.dequeueReusableCell(for: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
