//
//  GXChargingFeeConfirmVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/4.
//

import UIKit
import PromiseKit
import RxSwift
import MBProgressHUD

private let GX_NotifName_ChargingFeeConfirm_Scan = NSNotification.Name("GX_NotifName_ChargingFeeConfirm_Scan")

class GXChargingFeeConfirmVC: GXBaseViewController, GXChargingStoryboard {
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomLeftFee: UILabel!
    @IBOutlet weak var bottomLeftDw: UILabel!
    @IBOutlet weak var bottomRightFee: UILabel!
    @IBOutlet weak var bottomVipIV: UIImageView!
    @IBOutlet weak var bottomRightFeeLeftLC: NSLayoutConstraint!
    @IBOutlet weak var bottomTimeD: UILabel!
    @IBOutlet weak var bottomScanButton: UIButton!
    
    lazy var viewModel: GXChargingFeeConfirmViewModel = {
        return GXChargingFeeConfirmViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestConnectorConsumerLoad()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Fee Confirmation"
        self.gx_addBackBarButtonItem()
    }
    
}

private extension GXChargingFeeConfirmVC {
    
    func requestConnectorConsumerLoad() {
        self.view.layoutSkeletonIfNeeded()
        self.view.showAnimatedGradientSkeleton()
        let combinedPromise = when(fulfilled: [
            //self.viewModel.requestConnectorConsumerScan(),
            self.viewModel.requestVehicleConsumerList()
        ])
        firstly {
            combinedPromise
        }.done { models in
            self.view.hideSkeleton()
            self.updateBottomDataSource()
            self.notifiTableViewUpdateData()
        }.catch { error in
            self.view.hideSkeleton()
            GXToast.showError(text:error.localizedDescription)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func requestConnectorConsumerScan() {
        guard let qrcode = self.viewModel.scanData?.qrcode else { return }
        MBProgressHUD.showLoading()
        firstly {
            GXNWProvider.login_requestConnectorConsumerScan(qrcode: qrcode)
        }.done { model in
            MBProgressHUD.dismiss()
            self.viewModel.scanData = model.data
            self.updateBottomDataSource()
            self.notifiTableViewUpdateData()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func updateBottomDataSource() {
        guard let info = self.viewModel.scanData?.stationInfo else { return }
        /// bottomView
        self.bottomScanButton.setBackgroundColor(.gx_green, for: .normal)
        self.bottomScanButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        self.bottomTimeD.text = "Current time period \(info.period)"
        if GXUserManager.shared.isVip {
            self.bottomLeftFee.textColor = .gx_orange
            self.bottomLeftDw.textColor = .gx_orange
            self.bottomVipIV.isHidden = true
            self.bottomRightFeeLeftLC.constant = 8.0
            let vipFee = info.electricFee + info.serviceFeeVip
            self.bottomLeftFee.text = String(format: "$%.2f", vipFee)
            let omzFee = info.electricFee + info.serviceFee
            let omzFeeStr = String(format: "$%.2f/kWh", omzFee)
            let attrText = NSAttributedString.gx_strikethroughText(omzFeeStr, color: .gx_drakGray, font: .gx_font(size: 14))
            self.bottomRightFee.attributedText = attrText
        }
        else {
            self.bottomLeftFee.textColor = .gx_green
            self.bottomLeftDw.textColor = .gx_green
            self.bottomVipIV.isHidden = false
            self.bottomRightFeeLeftLC.constant = 40.0
            let omzFee = info.electricFee + info.serviceFee
            self.bottomLeftFee.text = String(format: "$%.2f", omzFee)
            let vipFee = info.electricFee + info.serviceFeeVip
            self.bottomRightFee.text = String(format: "$%.2f/kWh", vipFee)
        }
    }
    
    func notifiTableViewUpdateData() {
        NotificationCenter.default.post(name: GX_NotifName_ChargingFeeConfirm_Scan, object: self.viewModel.scanData)
    }
    
    @IBAction func startChargingButtonClicked(_ sender: Any?) {
        if self.viewModel.scanData?.status == "Preparing" {
            let vc =  GXChargingLaunchStatusVC.createVC(viewModel: self.viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let message = "Please connect the charging gun to start charging"
            GXUtil.showAlert(title: "Alert", message: message, cancelTitle: "OK", handler: { alert, index in
                self.requestConnectorConsumerScan()
            })
        }
    }
    
}

class GXChargingFeeConfirmTableVC: UITableViewController {
    private let disposeBag = DisposeBag()
    private var scanData: GXConnectorConsumerScanData?
    // Cell 0
    @IBOutlet weak var leftLineImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var qrcodeLabel: UILabel!
    @IBOutlet weak var vehicleContainerView: UIView!
    @IBOutlet weak var vehicleBackIView: UIImageView!
    @IBOutlet weak var vehicleNumLabel: UILabel!
    // Cell 1
    @IBOutlet weak var chargingFeeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    // Cell 2
    @IBOutlet weak var maxOccupyFeeLabel: UILabel!
    @IBOutlet weak var occupyFeeLabel: UILabel!
    // Cell 3
    @IBOutlet weak var freeParkingLabel: UILabel!
    // Cell 4
    @IBOutlet weak var advertView: UIView!
    @IBOutlet weak var advertTitleLabel: UILabel!
    @IBOutlet weak var advertInfoLabel: UILabel!
    @IBOutlet weak var advertKWhLabel: UILabel!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.leftLineImgView.setRoundedCorners([.topRight, .bottomRight], radius: 2.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewController()
        
        NotificationCenter.default.rx
            .notification(GX_NotifName_ChargingFeeConfirm_Scan)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                if let data = notifi.object as? GXConnectorConsumerScanData {
                    self?.scanData = data
                    self?.updateDataSource()
                }
            }).disposed(by: disposeBag)
    }
    
    private func setupViewController() {
        self.tableView.configuration(estimated: true)
        
        let lineColors: [UIColor] = [.gx_green, UIColor(hexString: "#278CFF")]
        self.leftLineImgView.image = UIImage(gradientColors: lineColors, style: .vertical, size: CGSize(width: 4, height: 14))
        
        let colors: [UIColor] = [.gx_green, .gx_blue]
        self.vehicleBackIView.image = UIImage(gradientColors: colors, style: .horizontal, size: CGSize(width: 10, height: 24))
    }
    
    func updateDataSource() {
        self.tableView.reloadData()
        // Cell 0
        if let vehicle = GXUserManager.shared.selectedVehicle {
            self.vehicleContainerView.isHidden = false
            self.vehicleNumLabel.text = vehicle.state + "-" + vehicle.carNumber
        }
        else {
            self.vehicleContainerView.isHidden = true
        }
        guard let scan = self.scanData else { return }
        guard let info = scan.stationInfo else { return }
        self.nameLabel.text = info.name
        self.qrcodeLabel.text = "Pile ID: \(scan.qrcode)"
        // Cell 1
        self.currentTimeLabel.text = info.period
        if GXUserManager.shared.isVip {
            let vipFee = info.electricFee + info.serviceFeeVip
            self.chargingFeeLabel.text = String(format: "$%.2f", vipFee)
        }
        else {
            let omzFee = info.electricFee + info.serviceFee
            self.chargingFeeLabel.text = String(format: "$%.2f", omzFee)
        }
        // Cell 2
        self.maxOccupyFeeLabel.text = "Max Occupancy Fee $\(GXUserManager.shared.paramsData?.occupyMax ?? "")"
        self.occupyFeeLabel.text = String(format: "$%.2f", info.occupyFee)
        // Cell 3
        self.freeParkingLabel.text = info.freeParking
        // Cell 4
        if GXUserManager.shared.isVip {
            self.advertTitleLabel.text = "VIP for Discounts"
        } else {
            self.advertTitleLabel.text = "Become a VIP for Discounts"
        }
        self.advertInfoLabel.text = GXUserManager.shared.paramsData?.memberReduction ?? ""
        self.advertKWhLabel.text = "$\(GXUserManager.shared.paramsData?.memberFee ?? "")"
    }
    
}

extension GXChargingFeeConfirmTableVC {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            if self.scanData?.stationInfo?.occupyFlag == GX_YES {
                return UITableView.automaticDimension
            } else {
                return 0
            }
        }
        else if indexPath.row == 3 {
            if self.scanData?.stationInfo?.freeParking.count ?? 0 > 0 {
                return UITableView.automaticDimension
            } else {
                return 0
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
}

extension GXChargingFeeConfirmTableVC {
    
    @IBAction func editButtonClicked(_ sender: Any?) {
        let vc = GXHomeDetailVehicleVC.xibViewController()
        vc.selectedAction = {[weak self] in
            guard let `self` = self else { return }
            self.updateDataSource()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func chargingFeeButtonClicked(_ sender: Any?) {
        guard let prices = self.scanData?.stationInfo?.prices else { return }
        let maxHeight = SCREEN_HEIGHT - 200
        let menu = GXHomeDetailPriceDetailsMenu(height: maxHeight)
        menu.bindView(prices: prices)
        menu.show(style: .sheetBottom, usingSpring: true)
    }
    
    @IBAction func advertButtonClicked(_ sender: Any?) {
        // 开通会员
        let vc = GXVipVC.xibViewController()
        vc.gx_addBackBarButtonItem()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
