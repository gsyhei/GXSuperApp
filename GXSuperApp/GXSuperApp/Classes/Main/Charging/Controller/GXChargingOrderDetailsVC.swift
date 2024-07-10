//
//  GXChargingOrderDetailsVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/6.
//

import UIKit
import MBProgressHUD
import PromiseKit
import SkeletonView

class GXChargingOrderDetailsVC: GXBaseViewController {
    @IBOutlet weak var appealButton: UIButton!
    @IBOutlet weak var appealInfoLabel: UILabel!
    @IBOutlet weak var payNowButton: UIButton!
    @IBOutlet weak var bottomHeightLC: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(estimated: true, separatorLeft: false)
            tableView.separatorColor = .gx_lineGray
            tableView.sectionHeaderHeight = 10
            tableView.sectionFooterHeight = .leastNormalMagnitude
            tableView.register(cellType: GXChargingOrderDetailsCell0.self)
            tableView.register(cellType: GXChargingOrderDetailsCell1.self)
            tableView.register(cellType: GXChargingOrderDetailsCell2.self)
            tableView.register(cellType: GXChargingOrderDetailsCell3.self)
            tableView.register(cellType: GXChargingOrderDetailsCell4.self)
            tableView.register(cellType: GXChargingOrderDetailsCell5.self)
            tableView.register(cellType: GXChargingOrderDetailsCell6.self)
            tableView.register(cellType: GXChargingOrderDetailsCell7.self)
            tableView.register(cellType: GXChargingOrderDetailsCell8.self)
        }
    }
    
    private lazy var tableHeader: GXChargingOrderDetailsHeader = {
        let rect = CGRect(origin: .zero, size: CGSize(width: self.view.width, height: 176))
        return GXChargingOrderDetailsHeader(frame: rect)
    }()
    
    private(set) lazy var viewModel: GXChargingOrderDetailsViewModel = {
        return GXChargingOrderDetailsViewModel().then {
            $0.autouUpdateDetailAction = {[weak self] in
                self?.updateDataSource()
            }
        }
    }()
    
    class func createVC(orderId: Int) -> GXChargingOrderDetailsVC {
        return GXChargingOrderDetailsVC.xibViewController().then {
            $0.hidesBottomBarWhenPushed = true
            $0.viewModel.orderId = orderId
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutSkeletonIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestOrderConsumerDetail()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Order Details"
        self.gx_addBackBarButtonItem()
        
        self.payNowButton.setBackgroundColor(.gx_green, for: .normal)
        self.payNowButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        self.tableView.tableHeaderView = self.tableHeader
    }
}

extension GXChargingOrderDetailsVC {
    
    func updateDataSource() {
        self.tableView.reloadData()
        guard let detail = self.viewModel.detailData else { return }
        
        self.tableHeader.bindView(model: detail)
        if detail.complainAvailable && (detail.orderStatus == "TO_PAY" || detail.orderStatus == "FINISHED") {
            self.appealButton.isHidden = false
            self.appealInfoLabel.isHidden = false
            self.bottomHeightLC.constant = 100
        }
        else {
            self.appealButton.isHidden = true
            self.appealInfoLabel.isHidden = true
            self.bottomHeightLC.constant = 64
        }
        if detail.orderStatus == "TO_PAY" {
            self.payNowButton.setTitle("Pay Now", for: .normal)
        }
        else {
            self.payNowButton.setTitle("Back Home", for: .normal)
        }
        self.updateFavoriteBarButtonItem()
    }
    
    func updateFavoriteBarButtonItem() {
        if self.viewModel.detailData?.favoriteFlag == GX_YES {
            let image = UIImage(named: "com_nav_ic_collect_selected")?.withRenderingMode(.alwaysOriginal)
            self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(requestFavoriteConsumerSave))
        }
        else {
            let image = UIImage(named: "com_nav_ic_collect_normal")?.withRenderingMode(.alwaysOriginal)
            self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(requestFavoriteConsumerSave))
        }
    }
    
}

extension GXChargingOrderDetailsVC {
    
    func requestOrderConsumerDetail() {
        self.view.showAnimatedGradientSkeleton()
        self.tableView.tableHeaderView?.showAnimatedGradientSkeleton()
        let combinedPromise = when(fulfilled: [
            self.viewModel.requestOrderConsumerDetail(),
            self.viewModel.requestWalletConsumerBalance()
        ])
        firstly {
            combinedPromise
        }.done { models in
            self.view.hideSkeleton()
            self.tableView.tableHeaderView?.hideSkeleton()
            self.updateDataSource()
        }.catch { error in
            self.view.hideSkeleton()
            self.tableView.tableHeaderView?.hideSkeleton()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func requestStationConsumerPrice(completion: GXActionBlock?) {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestStationConsumerPrice()
        }.done { model in
            MBProgressHUD.dismiss()
            completion?()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    @objc func requestFavoriteConsumerSave() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestFavoriteConsumerSave()
        }.done { model in
            MBProgressHUD.dismiss()
            self.updateFavoriteBarButtonItem()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
}

extension GXChargingOrderDetailsVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    // MARK - SkeletonTableViewDataSource
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        switch indexPath.row {
        case 0:
            return GXChargingOrderDetailsCell0.reuseIdentifier
        case 1:
            return GXChargingOrderDetailsCell1.reuseIdentifier
        case 2:
            return GXChargingOrderDetailsCell2.reuseIdentifier
        case 3:
            return GXChargingOrderDetailsCell3.reuseIdentifier
        case 4:
            return GXChargingOrderDetailsCell4.reuseIdentifier
        default:
            return ""
        }
    }
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        switch indexPath.row {
        case 0:
            let cell: GXChargingOrderDetailsCell0 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 1:
            let cell: GXChargingOrderDetailsCell1 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 2:
            let cell: GXChargingOrderDetailsCell2 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 3:
            let cell: GXChargingOrderDetailsCell3 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 4:
            let cell: GXChargingOrderDetailsCell4 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionIndexs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.sectionIndexs[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = self.viewModel.sectionIndexs[indexPath.section][indexPath.row]
        switch index {
        case 0:
            let cell: GXChargingOrderDetailsCell0 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.detailData)
            return cell
        case 1:
            let cell: GXChargingOrderDetailsCell1 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindDetailCell(model: self.viewModel.detailData)
            return cell
        case 2:
            let cell: GXChargingOrderDetailsCell2 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.detailData) {[weak self] _ in
                guard let `self` = self else { return }
                self.showChargingFeeInfo()
            }
            return cell
        case 3:
            let cell: GXChargingOrderDetailsCell3 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.detailData)
            return cell
        case 4:
            let cell: GXChargingOrderDetailsCell4 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.detailData)
            return cell
        case 5:
            let cell: GXChargingOrderDetailsCell5 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell5(model: self.viewModel.detailData)
            return cell
        case 6:
            let cell: GXChargingOrderDetailsCell6 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.balanceData)
            return cell
        case 7:
            let cell: GXChargingOrderDetailsCell7 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.detailData)
            return cell
        case 8:
            let cell: GXChargingOrderDetailsCell8 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.detailData)
            return cell
        case 9:
            let cell: GXChargingOrderDetailsCell5 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell9(model: self.viewModel.detailData) {[weak self] in
                guard let `self` = self else { return }
                self.showIdleFeeInfo()
            }
            return cell
        default: return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        GXBaseTableView.setTableView(tableView, cell: cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = self.viewModel.sectionIndexs[indexPath.section][indexPath.row]
        switch index {
        case 0: return 44
        case 1: return 200
        case 2: return 80
        case 3: return 156
        case 4: return 142
        case 5, 9: return 48
        case 6: return 54
        case 7: return 110
        case 8: return 146
        default: return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension GXChargingOrderDetailsVC {
    
    func showChargingFeeInfo() {
        self.requestStationConsumerPrice(completion: {[weak self] in
            guard let `self` = self else { return }
            guard let prices = self.viewModel.priceData?.prices else { return }
            let maxHeight = SCREEN_HEIGHT - 200
            let menu = GXHomeDetailPriceDetailsMenu(height: maxHeight)
            menu.bindView(prices: prices)
            menu.show(style: .sheetBottom, usingSpring: true)
        })
    }
    
    func showIdleFeeInfo() {
        let mins = "\(GXUserManager.shared.paramsData?.occupyStartTime ?? 0)"
        let maxOccupancy = "$\(GXUserManager.shared.paramsData?.occupyMax ?? "")"
        let text = "Idle fee will be charged \(mins) mins after the end of charging" + "\nOccupancy fee cap: " + maxOccupancy
        let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.gx_font(size: 16), .foregroundColor: UIColor.gx_drakGray]
        let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
        let range = NSRange(location: text.count - maxOccupancy.count, length: maxOccupancy.count)
        attributedText.addAttribute(.foregroundColor, value: UIColor.gx_orange, range: range)
        GXUtil.showAlert(title: "Idle Fee", messageAttributedText: attributedText, cancelTitle: "OK", handler: { alert, index in })
    }
    
}

extension GXChargingOrderDetailsVC {
    
    @IBAction func appealButtonClicked(_ sender: Any?) {
        
    }
    
    @IBAction func payNowButtonClicked(_ sender: Any?) {
        guard let detail = self.viewModel.detailData else { return }
        if detail.orderStatus == "TO_PAY" {

        }
        else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
}
