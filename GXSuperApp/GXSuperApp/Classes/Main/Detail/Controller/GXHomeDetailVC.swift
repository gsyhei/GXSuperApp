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
            tableView.register(cellType: GXHomeDetailCell3.self)
            tableView.register(cellType: GXHomeDetailCell4.self)
            tableView.register(cellType: GXHomeDetailCell5.self)
            tableView.register(cellType: GXHomeDetailCell6.self)
            tableView.register(cellType: GXHomeDetailCell7.self)
        }
    }
    @IBOutlet weak var advertView: UIView!
    @IBOutlet weak var bottomView: UIView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.showAnimatedGradientSkeleton()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
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
    
    // MARK - SkeletonTableViewDataSource
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        switch indexPath.row {
        case 0:
            return GXHomeDetailCell0.reuseIdentifier
        case 1:
            return GXHomeDetailCell1.reuseIdentifier
        case 2:
            return GXHomeDetailCell2.reuseIdentifier
        case 3:
            return GXHomeDetailCell3.reuseIdentifier
        case 4:
            return GXHomeDetailCell4.reuseIdentifier
        case 5:
            return GXHomeDetailCell5.reuseIdentifier
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
        case 3:
            let cell: GXHomeDetailCell3 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 4:
            let cell: GXHomeDetailCell4 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 5:
            let cell: GXHomeDetailCell5 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, prepareCellForSkeleton cell: UITableViewCell, at indexPath: IndexPath) {
        
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
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
        case 3:
            let cell: GXHomeDetailCell3 = tableView.dequeueReusableCell(for: indexPath)
            cell.allTimeAction = {[weak self] in
                guard let `self` = self else { return }
                self.showAllTimeMenu()
            }
            cell.safetyAction = {[weak self] in
                guard let `self` = self else { return }
                self.showSafetyMenu()
            }
            return cell
        case 4:
            let cell: GXHomeDetailCell4 = tableView.dequeueReusableCell(for: indexPath)
            return cell
        case 5:
            let cell: GXHomeDetailCell5 = tableView.dequeueReusableCell(for: indexPath)
            cell.moreAction = {[weak self] in
                guard let `self` = self else { return }
                self.showChargerStatusMenu()
            }
            return cell
        case 6:
            let cell: GXHomeDetailCell6 = tableView.dequeueReusableCell(for: indexPath)
            return cell
        case 7:
            let cell: GXHomeDetailCell7 = tableView.dequeueReusableCell(for: indexPath)
            return cell
        default: return UITableViewCell()
        }
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
        case 4:
            return 216
        case 5:
            return 252
        case 6:
            return 126
        case 7:
            return 66
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
        case 4:
            return UITableView.automaticDimension
        case 5:
            return 252
        case 6:
            return 126
        case 7:
            return 66
        default:
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

private extension GXHomeDetailVC {
    
    func showAllTimeMenu() {
        let height: CGFloat = SCREEN_HEIGHT - self.view.safeAreaInsets.top - 250
        let menu = GXHomeDetailPriceDetailsMenu(height: height)
        menu.show(style: .sheetBottom, usingSpring: true)
    }
    func showChargerStatusMenu() {
        let height: CGFloat = SCREEN_HEIGHT - self.view.safeAreaInsets.top - 280
        let menu = GXHomeDetailChargerStatusMenu(height: height)
        menu.show(style: .sheetBottom, usingSpring: true)
    }
    func showSafetyMenu() {
        let vc = GXWebViewController(urlString: "https://www.baidu.com", title: "Safety Instructions")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
