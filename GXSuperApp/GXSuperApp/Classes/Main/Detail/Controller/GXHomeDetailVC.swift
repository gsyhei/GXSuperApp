//
//  GXHomeDetailVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/20.
//

import UIKit
import SkeletonView
import PromiseKit
import MBProgressHUD
import GXRefresh

class GXHomeDetailVC: GXBaseViewController {
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomLeftFee: UILabel!
    @IBOutlet weak var bottomLeftDw: UILabel!
    @IBOutlet weak var bottomRightFee: UILabel!
    @IBOutlet weak var bottomVipIV: UIImageView!
    @IBOutlet weak var bottomRightFeeLeftLC: NSLayoutConstraint!
    @IBOutlet weak var bottomTimeD: UILabel!
    @IBOutlet weak var bottomScanButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(estimated: true)
            tableView.sectionHeaderHeight = 0
            tableView.sectionFooterHeight = 0
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
            tableView.register(cellType: GXHomeDetailCell0.self)
            tableView.register(cellType: GXHomeDetailCell1.self)
            tableView.register(cellType: GXHomeDetailCell2.self)
            tableView.register(cellType: GXHomeDetailCell3.self)
            tableView.register(cellType: GXHomeDetailCell4.self)
            tableView.register(cellType: GXHomeDetailCell5.self)
            tableView.register(cellType: GXHomeDetailCell6.self)
            tableView.register(cellType: GXHomeDetailCell7.self)
            tableView.register(cellType: GXHomeDetailCell8.self)
        }
    }
    
    private(set) lazy var viewModel: GXHomeDetailViewModel = {
        return GXHomeDetailViewModel()
    }()
    
    class func createVC(stationId: Int) -> GXHomeDetailVC {
        return GXHomeDetailVC.xibViewController().then {
            $0.viewModel.stationId = stationId
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutSkeletonIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestStationConsumerDetail()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Station Details"
        self.gx_addBackBarButtonItem()
        
        self.tableView.gx_header = GXRefreshNormalHeader(completion: { [weak self] in
            guard let `self` = self else { return }
            self.requestStationConsumerDetail(isShowHud: false)
        }).then { footer in
            footer.updateRefreshTitles()
        }
    }
    
    override func loginReloadViewData() {
        self.requestStationConsumerDetail()
    }
}

extension GXHomeDetailVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    // MARK - SkeletonTableViewDataSource
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
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
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.cellIndexs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = self.viewModel.cellIndexs[indexPath.row]
        switch index {
        case 0:
            let cell: GXHomeDetailCell0 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.detailData) {[weak self] in
                guard let `self` = self else { return }
                guard let images = self.viewModel.detailData?.aroundServicesArr else { return }
                let vc = GXHomeDetailEnvironmentVC(images: images)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        case 1:
            let cell: GXHomeDetailCell1 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.detailData)
            cell.sharedAction = {[weak self] in
                guard let `self` = self else { return }
                self.showSharedMenu()
            }
            cell.navigationAction = {[weak self] in
                guard let `self` = self else { return }
                self.showNavigationMenu()
            }
            cell.favoritedAction = {[weak self] button in
                guard let `self` = self else { return }
                self.requestFavoritedAction(button: button)
            }
            return cell
        case 2:
            let cell: GXHomeDetailCell2 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.detailData)
            return cell
        case 3:
            let cell: GXHomeDetailCell3 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(showPrices: self.viewModel.showPrices)
            cell.allTimeAction = {[weak self] in
                guard let `self` = self else { return }
                self.showAllTimeMenu()
            }
            cell.safetyAction = {[weak self] in
                guard let `self` = self else { return }
                self.gotoSafetyWebVC()
            }
            cell.costAction = {[weak self] in
                guard let `self` = self else { return }
                self.gotoCostWebVC()
            }
            return cell
        case 4:
            let cell: GXHomeDetailCell4 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.detailData, vehicle: GXUserManager.shared.selectedVehicle)
            cell.addAction = {[weak self] in
                guard let `self` = self else { return }
                self.gotoAddVehicleVC()
            }
            return cell
        case 5:
            let cell: GXHomeDetailCell5 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(items: self.viewModel.ccRowsList)
            cell.moreAction = {[weak self] in
                guard let `self` = self else { return }
                self.showChargerStatusMenu()
            }
            return cell
        case 6:
            let cell: GXHomeDetailCell6 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(list: self.viewModel.detailData?.aroundFacilitiesList)
            return cell
        case 7:
            let cell: GXHomeDetailCell7 = tableView.dequeueReusableCell(for: indexPath)
            cell.setCell7Type(model: self.viewModel.detailData)
            return cell
        case 8:
            let cell: GXHomeDetailCell8 = tableView.dequeueReusableCell(for: indexPath)
            cell.vipAction = {[weak self] in
                guard let `self` = self else { return }
                self.gotoVipVC()
            }
            return cell
        default: return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = self.viewModel.cellIndexs[indexPath.row]
        switch index {
        case 0: return 112
        case 1: return 198
        case 2: return 56
        case 3: return 264
        case 4: return 216
        case 5: return 173
        case 6: return 126
        case 7: return 66
        case 8: return 84
        default: return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // let index = self.viewModel.cellIndexs[indexPath.row]
    }
    
}

private extension GXHomeDetailVC {
    @IBAction func scanButtonClicked(_ sender: Any?) {
        if GXUserManager.shared.isLogin {
            let vc = GXQRCodeReaderVC.xibViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.didFindCodeAction = {[weak self] (model, scanVC) in
                guard let `self` = self else { return }
                let vc = GXChargingFeeConfirmVC.instantiate()
                vc.viewModel.scanData = model.data
                self.navigationController?.pushViewController(vc, animated: true)
            }
            self.present(vc, animated: true)
        }
        else {
            GXAppDelegate?.gotoLogin(from: self)
        }
    }
    
}

private extension GXHomeDetailVC {
    
    func requestStationConsumerDetail(isShowHud: Bool = true) {
        if isShowHud {
            self.view.showAnimatedGradientSkeleton()
        }
        let combinedPromise = when(fulfilled: [
            self.viewModel.requestStationConsumerDetail(),
            self.viewModel.requestConnectorConsumerList(),
            self.viewModel.requestVehicleConsumerList()
        ])
        firstly {
            combinedPromise
        }.done { models in
            if isShowHud {
                self.view.hideSkeleton()
            } else {
                self.view.hideSkeleton()
                self.tableView.gx_endRefreshing(isSucceed: true)
            }
            self.updateDetailDataSource()
        }.catch { error in
            self.view.hideSkeleton()
            if isShowHud {
                GXToast.showError(text:error.localizedDescription)
            } else {
                self.tableView.gx_endRefreshing(isSucceed: false, text: error.localizedDescription)
            }
        }
    }
    
    func requestVehicleConsumerList() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestVehicleConsumerList()
        }.done { models in
            MBProgressHUD.dismiss()
            self.updateDetailDataSource()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func requestFavoriteConsumerSave() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestFavoriteConsumerSave()
        }.done { isFavorite in
            MBProgressHUD.dismiss()
            self.tableView.reloadData()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func updateDetailDataSource() {
        guard let detail = self.viewModel.detailData else { return }
        
        self.tableView.reloadData()
        /// bottomView
        self.bottomScanButton.setBackgroundColor(.gx_green, for: .normal)
        self.bottomScanButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        self.bottomTimeD.text = "Current time period \(self.viewModel.detailData?.period ?? "")"
        if GXUserManager.shared.isVip {
            self.bottomLeftFee.textColor = .gx_orange
            self.bottomLeftDw.textColor = .gx_orange
            self.bottomVipIV.isHidden = true
            self.bottomRightFeeLeftLC.constant = 8.0
            let vipFee = detail.electricFee + detail.serviceFeeVip
            self.bottomLeftFee.text = String(format: "$%.2f", vipFee)
            let omzFee = detail.electricFee + detail.serviceFee
            let omzFeeStr = String(format: "$%.2f/kWh", omzFee)
            let attrText = NSAttributedString.gx_strikethroughText(omzFeeStr, color: .gx_drakGray, font: .gx_font(size: 14))
            self.bottomRightFee.attributedText = attrText
        }
        else {
            self.bottomLeftFee.textColor = .gx_green
            self.bottomLeftDw.textColor = .gx_green
            self.bottomVipIV.isHidden = false
            self.bottomRightFeeLeftLC.constant = 40.0
            if GXUserManager.shared.isLogin {
                let omzFee = detail.electricFee + detail.serviceFee
                self.bottomLeftFee.text = String(format: "$%.2f", omzFee)
                let vipFee = detail.electricFee + detail.serviceFeeVip
                self.bottomRightFee.text = String(format: "$%.2f/kWh", vipFee)
            }
            else {
                self.bottomLeftFee.text = "$*****"
                let attrText = NSAttributedString.gx_strikethroughText("$*****/kWh", color: .gx_drakGray, font: .gx_font(size: 14))
                self.bottomRightFee.attributedText = attrText
            }
        }
    }
    func showAllTimeMenu() {
        guard let prices = self.viewModel.detailData?.prices else { return }
        let maxHeight = SCREEN_HEIGHT - 200
        let menu = GXHomeDetailPriceDetailsMenu(height: maxHeight)
        menu.bindView(prices: prices)
        menu.show(style: .sheetBottom, usingSpring: true)
    }
    
    func showChargerStatusMenu() {
        let maxHeight = SCREEN_HEIGHT - 200
        let menu = GXHomeDetailChargerStatusMenu(height: maxHeight)
        menu.bindView(viewModel: self.viewModel)
        menu.show(style: .sheetBottom, usingSpring: true)
    }
    
    func gotoSafetyWebVC() {
        let vc = GXWebViewController(urlString: GXUtil.gx_h5Url(id: 6),
                                     title: "Safety Instructions")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoCostWebVC() {
        let vc = GXWebViewController(urlString: GXUtil.gx_h5Url(id: 5), 
                                     title: "Fee Description")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoAddVehicleVC() {
        if GXUserManager.shared.isLogin {
            if GXUserManager.shared.vehicleList.count > 0 {
                let vc = GXHomeDetailVehicleVC.xibViewController()
                vc.selectedAction = {[weak self] in
                    guard let `self` = self else { return }
                    self.tableView.reloadData()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = GXHomeDetailAddVehicleVC.xibViewController()
                vc.addCompletion = {[weak self] in
                    guard let `self` = self else { return }
                    self.requestVehicleConsumerList()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            GXAppDelegate?.gotoLogin(from: self)
        }
    }
    
    func showSharedMenu() {
        let itemsToShare = ["Shared", URL(string: "https://www.apple.com")!] as [Any]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view 
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func showNavigationMenu() {
        guard let detail = self.viewModel.detailData else { return }
        let coordinate = CLLocationCoordinate2D(latitude: detail.lat, longitude: detail.lng)
        XYNavigationManager.show(with: self, coordinate: coordinate, endAddress: detail.address)
    }
    
    func requestFavoritedAction(button: UIButton) {
        if GXUserManager.shared.isLogin {
            self.requestFavoriteConsumerSave()
        }
        else {
            GXAppDelegate?.gotoLogin(from: self)
        }
    }
    
    func gotoVipVC() {
        if GXUserManager.shared.isLogin {
            let vc = GXVipVC.xibViewController()
            vc.gx_addBackBarButtonItem()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            GXAppDelegate?.gotoLogin(from: self)
        }
    }

}
