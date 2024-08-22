//
//  GXChargingCarShowVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/10.
//

import UIKit
import MBProgressHUD
import PromiseKit

class GXChargingCarShowVC: GXBaseViewController, GXChargingStoryboard {
    @IBOutlet weak var carNumberLabel: UILabel!
    @IBOutlet weak var chargedTimeLabel: UILabel!
    @IBOutlet weak var chargedKwhLabel: UILabel!
    @IBOutlet weak var endChargingButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBarIView: UIImageView!
    @IBOutlet weak var progressBarRightLC: NSLayoutConstraint!
    @IBOutlet weak var smallCircleView: UIView!
    @IBOutlet weak var bigCircleView: UIView!
    
    weak var carShowTableVC: GXChargingCarShowTableViewVC?
    
    private var displayLink: CADisplayLink?
    private var progressConstant: CGFloat = 0
    private var maxProgressConstant: CGFloat {
        return SCREEN_WIDTH - 110.0
    }
    private var currentProgress: Int {
        let progress = 1.0 - self.progressBarRightLC.constant / self.maxProgressConstant
        return Int(ceil(progress * 100.0))
    }
    private lazy var viewModel: GXChargingCarShowViewModel = {
        return GXChargingCarShowViewModel().then {
            $0.autouUpdateDetailAction = {[weak self] isUpdate in
                guard let `self` = self else { return }
                if isUpdate {
                    self.updateDataSource()
                } else {
//                    let vc = GXChargingOrderDetailsVC.createVC(orderId: self.viewModel.orderId)
//                    self.navigationController?.pushByReturnToViewController(vc: vc, animated: true)
                }
            }
        }
    }()
    
    class func createVC(orderId: Int) -> GXChargingCarShowVC {
        return GXChargingCarShowVC.instantiate().then {
            $0.viewModel.orderId = orderId
        }
    }
    
    deinit {
        self.stopAnimation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? GXChargingCarShowTableViewVC
        vc?.viewModel = self.viewModel
        self.carShowTableVC = vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestOrderConsumerDetail()
    }
    
    override func setupViewController() {
        self.gx_addBackBarButtonItem()
        
        self.endChargingButton.setBackgroundColor(.gx_green, for: .normal)
        self.endChargingButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        let colors: [UIColor] = [.gx_green, .init(hexString: "#278CFF")]
        let imageSize = CGSize(width: 10, height: 40.0)
        self.progressBarIView.image = UIImage(gradientColors: colors, style: .horizontal, size: imageSize)
        self.progressLabel.text = "0%"
        self.view.layoutSubviews()
        self.progressBarRightLC.constant = self.maxProgressConstant
        
        self.startLoopCircleAnimation()
    }
    
    private func updateDataSource() {
        guard let detail = self.viewModel.detailData else { return }
        
        self.carNumberLabel.text = detail.carNumber.formatCarNumber
        self.chargedTimeLabel.text = "Charging will complete in " + GXUtil.gx_chargingTime(minute: detail.chargingDuration)
        self.chargedKwhLabel.text = "\(detail.power) kWh Charged"
        
        let progress = CGFloat(detail.soc) / 100.0
        self.updateBarProgress(to: progress)
    }
    
    @IBAction func endChargingButtonClicked(_ sender: Any?) {
        let title = "Sure you want to stop charging?"
        GXUtil.showAlert(title: title, actionTitle: "Stop charging", handler: { alert, index in
            guard index == 1 else { return }
            self.requestOrderConsumerStop()
        })
    }
    
    /// 测试动画效果用
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if abs(self.progressBarRightLC.constant - self.maxProgressConstant) <= 2 {
            self.updateBarProgress(to: 1.0)
        }
        else {
            self.updateBarProgress(to: 0.0)
        }
    }
    
}

extension GXChargingCarShowVC {
    
    func requestOrderConsumerDetail() {
        MBProgressHUD.showLoading()
        self.carShowTableVC?.tableView.isHidden = true
        let combinedPromise = when(fulfilled: [
            self.viewModel.requestOrderConsumerDetail(),
            self.viewModel.requestWalletConsumerBalance()
        ])
        firstly {
            combinedPromise
        }.done { models in
            MBProgressHUD.dismiss()
            self.updateDataSource()
            self.carShowTableVC?.updateDataSource()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func requestOrderConsumerStop() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestOrderConsumerStop()
        }.done { model in
            MBProgressHUD.dismiss()
            // 停止成功，去订单详情
            let vc = GXChargingOrderDetailsVC.createVC(orderId: self.viewModel.orderId)
            self.navigationController?.pushByReturnToViewController(vc: vc, animated: true)
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
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
    func startLoopCircleAnimation() {
        self.smallCircleView.layer.opacity = 0
        self.bigCircleView.layer.opacity = 0
        self.smallCircleView.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1)
        self.bigCircleView.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1)

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.8
        scaleAnimation.toValue = 1.3
        scaleAnimation.duration = 1.5
        scaleAnimation.autoreverses = false
        scaleAnimation.isRemovedOnCompletion = true
        scaleAnimation.repeatCount = 0

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        opacityAnimation.duration = 0.75
        opacityAnimation.autoreverses = true
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.repeatCount = 1

        let animationGroup = CAAnimationGroup()
        animationGroup.beginTime = 0
        animationGroup.duration = 3
        animationGroup.repeatCount = Float.infinity
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        
        let animationGroup1 = CAAnimationGroup()
        animationGroup1.timeOffset = 1.5
        animationGroup1.duration = 3
        animationGroup1.repeatCount = Float.infinity
        animationGroup1.animations = [scaleAnimation, opacityAnimation]
        
        self.smallCircleView.layer.add(animationGroup, forKey: "scaleAnimation1")
        self.bigCircleView.layer.add(animationGroup1, forKey: "scaleAnimation2")
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
    
    weak var viewModel: GXChargingCarShowViewModel!
    
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
    }
    
    func updateDataSource() {
        guard let detail = self.viewModel.detailData else { return }
        
        self.tableView.isHidden = false
        self.chargedKWLabel.text = String(format: "%g KW", Float(detail.power)/1000.0)
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
        let vc = GXMineRechargeVC.xibViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
