//
//  GXChargingCarShowVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/10.
//

import UIKit
import MBProgressHUD
import PromiseKit

private let GX_NotifName_GXChargingCarShow_Data = NSNotification.Name("GX_NotifName_GXChargingCarShow_Data")
class GXChargingCarShowVC: GXBaseViewController, GXChargingStoryboard {
    @IBOutlet weak var carNumberLabel: UILabel!
    @IBOutlet weak var chargedTimeLabel: UILabel!
    @IBOutlet weak var chargedKwhLabel: UILabel!
    @IBOutlet weak var endChargingButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBarIView: UIImageView!
    @IBOutlet weak var progressBarRightLC: NSLayoutConstraint!
    
    private var displayLink: CADisplayLink?
    private var progressConstant: CGFloat = 0
    private var maxProgressConstant: CGFloat {
        return SCREEN_WIDTH - 110.0
    }
    private var currentProgress: Int {
        let progress = 1.0 - self.progressBarRightLC.constant / self.maxProgressConstant
        return Int(ceil(progress * 100.0))
    }
    private var detailData: GXChargingOrderDetailData? {
        didSet {
            self.updateDataSource()
        }
    }
    
    deinit {
        self.stopAnimation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.rx
            .notification(GX_NotifName_GXChargingCarShow_Data)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                if let data = notifi.object as? GXChargingOrderDetailData {
                    self?.detailData = data
                }
            }).disposed(by: disposeBag)
    }
    
    override func setupViewController() {
        self.endChargingButton.setBackgroundColor(.gx_green, for: .normal)
        self.endChargingButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        let colors: [UIColor] = [.gx_green, .init(hexString: "#278CFF")]
        let imageSize = CGSize(width: 10, height: 40.0)
        self.progressBarIView.image = UIImage(gradientColors: colors, style: .horizontal, size: imageSize)
        self.progressLabel.text = "0%"
        self.view.layoutSubviews()
        self.progressBarRightLC.constant = self.maxProgressConstant
    }
    
    private func updateDataSource() {
        guard let detail = self.detailData else { return }
        
        self.carNumberLabel.text = detail.carNumber.formatCarNumber
        self.chargedTimeLabel.text = "Charging will complete in " + GXUtil.gx_chargingTime(minute: detail.chargingDuration)
        self.chargedKwhLabel.text = "\(detail.power) kWh Charged"
        
        let progress = CGFloat(detail.soc) / 100.0
        self.updateBarProgress(to: progress)
    }
}

extension GXChargingCarShowVC {
    func updateBarProgress(to progress: CGFloat) {
        let maxWith = self.maxProgressConstant
        let constant = maxWith - maxWith * progress
        self.progressConstant = constant
        self.startAnimation()
    }
    func stopAnimation() {
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
    func startAnimation() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(displayLink:)))
        self.displayLink?.add(to: .current, forMode: .common)
        self.displayLink?.preferredFramesPerSecond = 60
    }
    @objc func handleDisplayLink(displayLink: CADisplayLink) {
        self.progressLabel.text = "\(self.currentProgress)%"
        let speed: CGFloat = self.progressBarRightLC.constant >= self.progressConstant ? -2 : 2
        if abs(self.progressBarRightLC.constant - self.progressConstant) > abs(speed) {
            self.progressBarRightLC.constant += speed
        } else {
            self.stopAnimation()
        }
    }
}

class GXChargingCarShowTableViewVC: UITableViewController {
    @IBOutlet weak var cell1ContainerView: UIView!
    @IBOutlet weak var cell2ContainerView: UIView!
    @IBOutlet weak var cell3ContainerView: UIView!
    
    @IBOutlet weak var chargedKWLabel: UILabel!
    @IBOutlet weak var chargedVLabel: UILabel!
    @IBOutlet weak var chargedALabel: UILabel!
    @IBOutlet weak var chargingFeeLabel: UILabel!
    @IBOutlet weak var idleFeeLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var rechargeButton: UIButton!

    private lazy var viewModel: GXChargingCarShowViewModel = {
        return GXChargingCarShowViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cell1ContainerView.layer.shadowRadius = 6.0
        self.cell1ContainerView.layer.shadowColor = UIColor.gx_gray.cgColor
        self.cell1ContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.cell1ContainerView.layer.shadowOpacity = 0.5
        
        self.cell2ContainerView.layer.shadowRadius = 6.0
        self.cell2ContainerView.layer.shadowColor = UIColor.gx_gray.cgColor
        self.cell2ContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.cell2ContainerView.layer.shadowOpacity = 0.5
        
        self.cell3ContainerView.layer.shadowRadius = 6.0
        self.cell3ContainerView.layer.shadowColor = UIColor.gx_gray.cgColor
        self.cell3ContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.cell3ContainerView.layer.shadowOpacity = 0.5
        
        self.rechargeButton.setBackgroundColor(.gx_green, for: .normal)
        self.rechargeButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        
        /// 网络请求
        self.requestOrderConsumerStart()
    }
    
    private func updateDataSource() {
        guard let detail = self.viewModel.detailData else { return }
        
        self.tableView.isHidden = false
        self.chargedKWLabel.text = "\(detail.power) KW"
        self.chargedVLabel.text = "\(detail.voltage) V"
        self.chargedALabel.text = "\(detail.current) A"
        let meterFree = detail.powerFee + detail.serviceFee
        self.chargingFeeLabel.text = String(format: "$%.2f", meterFree)
        self.idleFeeLabel.text = "$\(detail.occupyPrice)"
        
        if let balance = self.viewModel.balanceData {
            self.balanceLabel.text = String(format: "$%.2f", balance.available)
        }
    }
}

extension GXChargingCarShowTableViewVC {
    
    func requestOrderConsumerStart() {
        MBProgressHUD.showLoading()
        self.tableView.isHidden = true
        let combinedPromise = when(fulfilled: [
            self.viewModel.requestOrderConsumerDetail(),
            self.viewModel.requestWalletConsumerBalance()
        ])
        firstly {
            combinedPromise
        }.done { models in
            MBProgressHUD.dismiss()
            self.updateDataSource()
            self.notifiTableViewUpdateData()
        }.catch { error in
            MBProgressHUD.dismiss()
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
    
    func notifiTableViewUpdateData() {
        NotificationCenter.default.post(name: GX_NotifName_GXChargingCarShow_Data, object: self.viewModel.detailData)
    }
    
}

extension GXChargingCarShowTableViewVC {
    
    @IBAction func chargingFeeButtonClicked(_ sender: Any?) {
        self.requestStationConsumerPrice(completion: {[weak self] in
            guard let `self` = self else { return }
            guard let prices = self.viewModel.priceData?.prices else { return }
            let maxHeight = SCREEN_HEIGHT - 200
            let menu = GXHomeDetailPriceDetailsMenu(height: maxHeight)
            menu.bindView(prices: prices)
            menu.show(style: .sheetBottom, usingSpring: true)
        })
    }
    
    @IBAction func idleFeeButtonClicked(_ sender: Any?) {
        let mins = "\(GXUserManager.shared.paramsData?.occupyStartTime ?? 0)"
        let maxOccupancy = "$\(GXUserManager.shared.paramsData?.occupyMax ?? "")"
        let text = "Idle fee will be charged \(mins) mins after the end of charging" + "\nOccupancy fee cap: " + maxOccupancy
        let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.gx_font(size: 16), .foregroundColor: UIColor.gx_drakGray]
        let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
        let range = NSRange(location: text.count - maxOccupancy.count, length: maxOccupancy.count)
        attributedText.addAttribute(.foregroundColor, value: UIColor.gx_orange, range: range)
        GXUtil.showAlert(title: "Idle Fee", messageAttributedText: attributedText, cancelTitle: "OK", handler: { alert, index in })
    }
    
    @IBAction func rechargeButtonClicked(_ sender: Any?) {
        
    }
}
