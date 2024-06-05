//
//  GXPtActivitySelectPayVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/1.
//

import UIKit
import MBProgressHUD
import XCGLogger

class GXPtActivitySelectPayVC: GXBaseViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tableView: GXBaseTableView!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!

    private lazy var viewModel: GXPtActivitySelectPayViewModel = {
        return GXPtActivitySelectPayViewModel()
    }()

    class func createVC(infoData: GXActivityBaseInfoData?, signData: GXSignActivityData) -> GXPtActivitySelectPayVC {
        return GXPtActivitySelectPayVC.xibViewController().then {
            $0.viewModel.infoData = infoData
            $0.viewModel.signData = signData
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "确认订单"
        self.gx_addBackBarButtonItem()

        let colors: [UIColor] = [
            .hexWithAlpha(hexString: "#80FBAD", alpha: 1.0),
            .hexWithAlpha(hexString: "#FFFFFF", alpha: 1.0)
        ]
        let backgroundImage = UIImage(gradientColors: colors, style: .vertical)
        self.backgroundImageView.image = backgroundImage

        self.payButton.setBackgroundColor(.gx_green, for: .normal)
        self.priceLabel.text = String(format: "￥%.2f", self.viewModel.signData.totalPrice)

        self.tableView.separatorColor = .gx_background
        self.tableView.register(headerFooterViewType: GXPtActivityOrderPayHeader.self)
        self.tableView.register(cellType: GXPtActivityOrderCell.self)
        self.tableView.register(cellType: GXPtActivitySelectPayCell.self)
        self.tableView.reloadData()
    }

}

extension GXPtActivitySelectPayVC {
    @IBAction func payButtonClicked(_ sender: UIButton) {
        guard let indexPath = self.tableView.indexPathForSelectedRow else {
            GXToast.showError(text: "请选择支付方式", to: self.view)
            return
        }
        if indexPath.row == 1 {
            self.requestPayAlipay()
        }
        else {
            self.requestPayWechat()
        }
    }
}

extension GXPtActivitySelectPayVC {
    func requestPayAlipay() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestPayAlipay {[weak self] data in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.payOrderAlipay(data: data)
        } failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        }
    }
    func requestPayWechat() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestPayWechat {[weak self] data in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.payOrderWxPay(data: data)
        } failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        }
    }
    func payOrderAlipay(data: String?) {
        guard let payOrder = data else {
            GXToast.showError(text: "订单错误", to: self.view)
            return
        }
        // NOTE: 调用支付结果开始支付
        AlipaySDK.defaultService().payOrder(payOrder, fromScheme: "hvalisdk") { resultDic in
            XCGLogger.info("result = \(resultDic ?? [:])")
            let resultStatus = resultDic?["resultStatus"] as? String
            if resultStatus == "9000" {// 支付成功
                let vc = GXPtActivityPaySuccVC.createVC(infoData: self.viewModel.infoData,
                                                        signData: self.viewModel.signData)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                GXToast.showError(text: resultDic?["memo"] as? String, to: self.view)
            }
        }
    }
    func payOrderWxPay(data: Dictionary<String, Any>?) {
        guard let params = data else {
            GXToast.showError(text: "订单错误", to: self.view)
            return
        }
        GXWechatManager.shared.payOrder(params: params) { error in
            if error != nil {
                GXToast.showError(text: "支付失败", to: self.view)
            } else {
                let vc = GXPtActivityPaySuccVC.createVC(infoData: self.viewModel.infoData,
                                                        signData: self.viewModel.signData)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension GXPtActivitySelectPayVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: GXPtActivityOrderCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindModel(data: self.viewModel.infoData,
                           totalPrice: self.viewModel.signData.totalPrice,
                           isHiddenLocation: true)
            return cell
        }
        let cell: GXPtActivitySelectPayCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bindCell(index: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let header = tableView.dequeueReusableHeaderFooterView(GXPtActivityOrderPayHeader.self)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return .zero
        }
        return 36.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30.0
        }
        return .zero
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100.0
        }
        return .zero
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }
        return 50.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
    }
}

