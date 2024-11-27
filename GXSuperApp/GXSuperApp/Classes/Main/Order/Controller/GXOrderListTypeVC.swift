//
//  GXOrderListTypeVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/9.
//

import UIKit
import PromiseKit
import GXRefresh
import SkeletonView
import MBProgressHUD
import Popover

class GXOrderListTypeVC: GXBaseViewController {
    private lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .grouped).then {
            $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 12))
            $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            $0.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
            $0.backgroundColor = .gx_background
            $0.separatorColor = .gx_lineGray
            $0.sectionHeaderHeight = 10
            $0.sectionFooterHeight = .leastNormalMagnitude
            $0.allowsSelection = false
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXChargingOrderDetailsCell1.self)
            $0.register(cellType: GXChargingOrderDetailsCell2.self)
            $0.register(cellType: GXChargingOrderDetailsCell3.self)
            $0.register(cellType: GXChargingOrderDetailsCell4.self)
            $0.register(cellType: GXChargingOrderDetailsCell5.self)
            $0.register(cellType: GXChargingOrderDetailsCell10.self)
        }
    }()
    
    private lazy var popover: Popover = {
        let color = UIColor(white: 0, alpha: 0.05)
        let size = CGSize(width: 16.0, height: 8.0)
        let options:[PopoverOption] = [
            .type(.up),
            .sideEdge(24.0),
            .blackOverlayColor(.clear),
            .color(.white),
            .arrowSize(size),
            .animationIn(0.3)
        ]
        return Popover(options: options).then {
            $0.layer.masksToBounds = false
            $0.layer.shadowColor = UIColor.gx_gray.cgColor
            $0.layer.shadowRadius = 16.0
            $0.layer.shadowOpacity = 1.0
        }
    }()
    
    private(set) lazy var viewModel: GXOrderListTypeViewModel = {
        return GXOrderListTypeViewModel()
    }()
    
    required init(orderStatus: GXOrderStatus) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel.orderStatus = orderStatus
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutSkeletonIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestOrderConsumerList()
    }
    
    override func viewDidAppearForAfterLoading() {
        self.requestOrderConsumerList(isRefresh: true, isShowHud: false)
    }

    override func setupViewController() {
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        self.view.isSkeletonable = true
        self.tableView.isSkeletonable = true
        
        self.tableView.gx_header = GXRefreshNormalHeader(completion: { [weak self] in
            self?.requestOrderConsumerList(isRefresh: true, isShowHud: false)
        }).then({ header in
            header.updateRefreshTitles()
        })
        self.tableView.gx_footer = GXRefreshNormalFooter(completion: { [weak self] in
            self?.requestOrderConsumerList(isRefresh: false, isShowHud: false)
        }).then { footer in
            footer.updateRefreshTitles()
        }
    }
}

extension GXOrderListTypeVC {
    
    func requestOrderConsumerList(isRefresh: Bool = true, isShowHud: Bool = true) {
        if isShowHud {
            self.view.showAnimatedGradientSkeleton()
        }
        firstly {
            self.viewModel.requestOrderConsumerList(isRefresh: isRefresh)
        }.done { (model, isLastPage) in
            self.view.hideSkeleton()
            if isShowHud {
                self.tableView.gx_reloadData()
            } else {
                self.tableView.gx_reloadData()
            }
            self.tableView.gx_endRefreshing(isNoMore: isLastPage, isSucceed: true)
        }.catch { error in
            self.view.hideSkeleton()
            if isShowHud {
                GXToast.showError(text:error.localizedDescription)
            }
            self.tableView.gx_endRefreshing(isNoMore: false, isSucceed: false)
        }
    }
    
    func requestStationConsumerPrice(stationId: Int?, completion: GXActionBlock?) {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestStationConsumerPrice(stationId: stationId)
        }.done { model in
            MBProgressHUD.dismiss()
            completion?()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    func requestOrderConsumerPay(cellModel: GXChargingOrderDetailCellModel) {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestOrderConsumerPay(orderId: cellModel.item.id)
        }.done { model in
            MBProgressHUD.dismiss()
            cellModel.item.orderStatus = .FINISHED
            self.tableView.gx_reloadData()
            NotificationCenter.default.post(name: GX_NotifName_UpdateOrderDoing, object: nil)
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
}

extension GXOrderListTypeVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    // MARK - SkeletonTableViewDataSource
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        switch indexPath.row {
        case 0:
            return GXChargingOrderDetailsCell1.reuseIdentifier
        case 1:
            return GXChargingOrderDetailsCell2.reuseIdentifier
        case 2:
            return GXChargingOrderDetailsCell3.reuseIdentifier
        case 3:
            return GXChargingOrderDetailsCell4.reuseIdentifier
        case 4:
            return GXChargingOrderDetailsCell5.reuseIdentifier
        case 5:
            return GXChargingOrderDetailsCell10.reuseIdentifier
        default:
            return ""
        }
    }
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        switch indexPath.row {
        case 0:
            let cell: GXChargingOrderDetailsCell1 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 1:
            let cell: GXChargingOrderDetailsCell2 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 2:
            let cell: GXChargingOrderDetailsCell3 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 3:
            let cell: GXChargingOrderDetailsCell4 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 4:
            let cell: GXChargingOrderDetailsCell5 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 5:
            let cell: GXChargingOrderDetailsCell10 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.cellList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let model = self.viewModel.cellList[section]
        if model.isOpen {
            return self.viewModel.cellList[section].rowsIndexs.count
        }
        else {
            return self.viewModel.cellList[section].closeRowsIndexs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.viewModel.cellList[indexPath.section]
        let index = model.isOpen ? model.rowsIndexs[indexPath.row] : model.closeRowsIndexs[indexPath.row]
        switch index {
        case 1:
            let cell: GXChargingOrderDetailsCell1 = tableView.dequeueReusableCell(for: indexPath)
            cell.isShowOpen = true
            cell.bindListCell(model: model.item, isOpen: model.isOpen)
            cell.openAction = {[weak self] isOpen in
                guard let `self` = self else { return }
                model.isOpen = isOpen
                self.tableView.reloadSection(indexPath.section, with: .automatic)
            }
            return cell
        case 2:
            let cell: GXChargingOrderDetailsCell2 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: model.item) {[weak self] model in
                guard let `self` = self else { return }
                self.showChargingFeeInfo(stationId: model?.stationId)
            }
            return cell
        case 3:
            let cell: GXChargingOrderDetailsCell3 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: model.item)
            return cell
        case 4:
            let cell: GXChargingOrderDetailsCell4 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: model.item)
            return cell
        case 5:
            let cell: GXChargingOrderDetailsCell5 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell5(model: model.item)
            return cell
        case 10:
            let cell: GXChargingOrderDetailsCell10 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: model.item, section: indexPath.section) {[weak self] (cell10, button, section) in
                guard let `self` = self else { return }
                self.clickedSectionCellAction(cell: cell10, button: button, section: section)
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
        let index = self.viewModel.cellList[indexPath.section].rowsIndexs[indexPath.row]
        switch index {
        case 1: return 200
        case 2: return 80
        case 3: return 156
        case 4: return 142
        case 5: return 48
        case 10: return 44
        default: return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension GXOrderListTypeVC {
    
    func showChargingFeeInfo(stationId: Int?) {
        self.requestStationConsumerPrice(stationId: stationId, completion: {[weak self] in
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
    
    func clickedSectionCellAction(cell: GXChargingOrderDetailsCell10, button: UIButton, section: Int) {
        guard let title = button.title(for: .normal) else { return }
        let model = self.viewModel.cellList[section]
        switch title {
        case "View":
            if model.item.orderStatus == .CHARGING {
                let vc = GXChargingCarShowVC.createVC(orderId: model.item.id)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = GXChargingOrderDetailsVC.createVC(orderId: model.item.id)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case "Pay":
            self.requestOrderConsumerPay(cellModel: model)
        case "More":
            let rect = button.convert(button.frame, from: cell.contentView)
            let btnRect = button.convert(rect, to: self.view)
            let point = CGPoint(x: btnRect.origin.x + button.width/2, y: btnRect.origin.y)
            var list: [GXOrderPopoverListModel] = []
            
            if !model.item.freeParking.isEmpty {
                list.append(GXOrderPopoverListModel(title: "Parking Discount", type: 0))
            }
            if model.item.complainAvailable || !model.item.complainId.isEmpty {
                list.append(GXOrderPopoverListModel(title: "Order Help", type: 1))
            }
            let listView = GXOrderPopoverListView(list: list) {[weak self] item in
                guard let `self` = self else { return }
                self.popover.dismiss()
                switch item.type {
                case 0:
                    self.showParkingDiscount(model: model)
                case 1:
                    let vc = GXOrderAppealVC.createVC(data: model.item)
                    self.navigationController?.pushViewController(vc, animated: true)
                default: break
                }
            }
            self.popover.show(listView, point: point, inView: self.view)
        default: break
        }
    }
    
    func showParkingDiscount(model: GXChargingOrderDetailCellModel) {
        GXUtil.showAlert(title: "Parking Fee Reduction", message: model.item.freeParking, cancelTitle: "OK", handler: { alert, index in })
    }
    
}
