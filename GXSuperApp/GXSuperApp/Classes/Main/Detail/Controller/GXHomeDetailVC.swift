//
//  GXHomeDetailVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/20.
//

import UIKit
import SkeletonView

class GXHomeDetailVC: GXBaseViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(estimated: true)
            tableView.sectionHeaderHeight = 0
            tableView.sectionFooterHeight = 0
            tableView.register(cellType: GXHomeDetailCell0.self)
            tableView.register(cellType: GXHomeDetailCell1.self)
            tableView.register(cellType: GXHomeDetailCell2.self)
        }
    }
    @IBOutlet weak var advertView: UIView!
    @IBOutlet weak var bottomView: UIView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.backgroundColor = .white
        self.view.showAnimatedGradientSkeleton()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.tableView.backgroundColor = .gx_background
            self.view.hideSkeleton()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Station Details"
        self.gx_addBackBarButtonItem()
        

    }

}

extension GXHomeDetailVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: GXHomeDetailCell0 = tableView.dequeueReusableCell(for: indexPath)
            return cell
        case 1:
            let cell: GXHomeDetailCell1 = tableView.dequeueReusableCell(for: indexPath)
            return cell
        case 2:
            let cell: GXHomeDetailCell2 = tableView.dequeueReusableCell(for: indexPath)
            return cell
        default: return UITableViewCell()
        }
    }
    
    // MARK - SkeletonTableViewDataSource
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        switch indexPath.row {
        case 0:
            return GXHomeDetailCell0.reuseIdentifier
        case 1:
            return GXHomeDetailCell1.reuseIdentifier
        case 2:
            return GXHomeDetailCell2.reuseIdentifier
        default:
            return ""
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        switch indexPath.row {
        case 0:
            let cell: GXHomeDetailCell0 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 1:
            let cell: GXHomeDetailCell1 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 2:
            let cell: GXHomeDetailCell2 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, prepareCellForSkeleton cell: UITableViewCell, at indexPath: IndexPath) {
        
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 112
        case 1:
            return 198
        case 2:
            return 56
        case 3:
            return 264
        default:
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 112
        case 1:
            return UITableView.automaticDimension
        case 2:
            return 56
        case 3:
            return 264
        default:
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}


