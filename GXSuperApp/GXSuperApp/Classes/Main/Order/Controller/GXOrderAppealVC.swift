//
//  GXOrderAppealVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/11.
//

import UIKit
import MBProgressHUD
import PromiseKit

class GXOrderAppealVC: GXBaseViewController {
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tableBottomLC: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(estimated: true, separatorLeft: false)
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 12))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
            tableView.backgroundColor = .gx_background
            tableView.separatorColor = .gx_lineGray
            tableView.sectionHeaderHeight = 10
            tableView.sectionFooterHeight = .leastNormalMagnitude
            tableView.register(cellType: GXChargingOrderDetailsCell1.self)
            tableView.register(cellType: GXChargingOrderDetailsCell2.self)
            tableView.register(cellType: GXChargingOrderDetailsCell3.self)
            tableView.register(cellType: GXChargingOrderDetailsCell4.self)
            tableView.register(cellType: GXChargingOrderDetailsCell5.self)
            tableView.register(cellType: GXOrderAppealShowCell.self)
            tableView.register(cellType: GXOrderAppealCell.self)
        }
    }
    
    private(set) lazy var viewModel: GXOrderAppealViewModel = {
        return GXOrderAppealViewModel()
    }()
    
    class func createVC(data: GXChargingOrderDetailData) -> GXOrderAppealVC {
        return GXOrderAppealVC.xibViewController().then {
            $0.viewModel.updateDataSource(item: data)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestorderConsumerComplainDetail()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Order Help"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)
        
        self.submitButton.setBackgroundColor(.gx_gray, for: .disabled)
        self.submitButton.setBackgroundColor(.gx_green, for: .normal)
        self.submitButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        self.updateDataSource()
    }
    
}

private extension GXOrderAppealVC {
    
    func requestorderConsumerComplainDetail() {
        MBProgressHUD.showLoading()
        let combinedPromise = when(fulfilled: [
            self.viewModel.requestDictListAvailable(),
            self.viewModel.requestOrderConsumerComplainDetail()
        ])
        firstly {
            combinedPromise
        }.done { models in
            MBProgressHUD.dismiss()
            self.updateDataSource()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
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
    
    func requestOrderConsumerComplainSave() {
        MBProgressHUD.showLoading()
        let combinedPromise = GXNWProvider.login_requestUploadFiles(assets: self.viewModel.images)
        firstly {
            combinedPromise
        }.then { models in
            self.viewModel.requestOrderConsumerComplainSave()
        }.done { model in
            MBProgressHUD.dismiss()
            GXToast.showSuccess(text: "Submission success. We will process it within 3 working days")
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func updateDataSource() {
        self.tableView.reloadData()
        if self.viewModel.complainData != nil {
            self.submitButton.isHidden = true
            self.tableBottomLC.constant = 0
        }
        else {
            self.submitButton.isHidden = false
            self.tableBottomLC.constant = 67
        }
    }
    
}

extension GXOrderAppealVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            guard let cellModel = self.viewModel.detailCellModel else { return 0 }
            return self.viewModel.isOpenDetail ? cellModel.rowsIndexs.count : cellModel.closeRowsIndexs.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let index = self.viewModel.detailCellModel?.rowsIndexs[indexPath.row] ?? 0
            switch index {
            case 1:
                let cell: GXChargingOrderDetailsCell1 = tableView.dequeueReusableCell(for: indexPath)
                cell.isShowOpen = true
                cell.bindListCell(model: self.viewModel.detailCellModel?.item, isOpen: self.viewModel.isOpenDetail)
                cell.openAction = {[weak self] isOpen in
                    guard let `self` = self else { return }
                    self.viewModel.isOpenDetail = isOpen
                    self.tableView.reloadSection(0, with: .automatic)
                }
                return cell
            case 2:
                let cell: GXChargingOrderDetailsCell2 = tableView.dequeueReusableCell(for: indexPath)
                cell.bindCell(model: self.viewModel.detailCellModel?.item) {[weak self] model in
                    guard let `self` = self else { return }
                    self.showChargingFeeInfo(stationId: model?.stationId)
                }
                return cell
            case 3:
                let cell: GXChargingOrderDetailsCell3 = tableView.dequeueReusableCell(for: indexPath)
                cell.bindCell(model: self.viewModel.detailCellModel?.item)
                return cell
            case 4:
                let cell: GXChargingOrderDetailsCell4 = tableView.dequeueReusableCell(for: indexPath)
                cell.bindCell(model: self.viewModel.detailCellModel?.item)
                return cell
            case 5:
                let cell: GXChargingOrderDetailsCell5 = tableView.dequeueReusableCell(for: indexPath)
                cell.bindCell5(model: self.viewModel.detailCellModel?.item)
                return cell
            default:
                return UITableViewCell()
            }
        }
        else {
            if let complainData = self.viewModel.complainData {
                let cell: GXOrderAppealShowCell = tableView.dequeueReusableCell(for: indexPath)
                cell.bindCell(model: complainData, superVC: self)
                return cell
            }
            else {
                let cell: GXOrderAppealCell = tableView.dequeueReusableCell(for: indexPath)
                cell.bindCell(superVC: self) {[weak self] isSubmit in
                    guard let `self` = self else { return }
                    self.submitButton.isEnabled = isSubmit
                }
                return cell
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        GXBaseTableView.setTableView(tableView, cell: cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let index = self.viewModel.detailCellModel?.rowsIndexs[indexPath.row] ?? 0
            switch index {
            case 1: return 200
            case 2: return 80
            case 3: return 156
            case 4: return 142
            case 5: return 48
            default: return .zero
            }
        }
        else {
            return 300.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

private extension GXOrderAppealVC {
    
    @IBAction func submitButtonClicked(_ sender: Any?) {
        self.requestOrderConsumerComplainSave()
    }
    
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
    
}


