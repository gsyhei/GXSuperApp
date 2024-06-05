//
//  GXPtActivityPaySuccVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/1.
//

import UIKit
import MBProgressHUD
import XCGLogger

class GXPtActivityPaySuccVC: GXBaseViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tableView: GXBaseTableView!
    @IBOutlet weak var backButton: UIButton!

    var infoData: GXActivityBaseInfoData?
    var signData: GXSignActivityData?

    private var viewModel: GXMinePtOrderDetailViewModel = {
        return GXMinePtOrderDetailViewModel()
    }()

    class func createVC(infoData: GXActivityBaseInfoData?, signData: GXSignActivityData?) -> GXPtActivityPaySuccVC {
        return GXPtActivityPaySuccVC.xibViewController().then {
            $0.infoData = infoData
            $0.signData = signData
            $0.viewModel.orderSn = signData?.orderSn
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.infoData?.activityMode == 2 && (self.viewModel.orderSn?.count ?? 0) > 0 {
            self.requestGetSelectByOrderSn()
        }
    }

    override func setupViewController() {
        self.title = "报名成功"
        self.gx_addBackBarButtonItem()

        let colors: [UIColor] = [
            .hexWithAlpha(hexString: "#80FBAD", alpha: 1.0),
            .hexWithAlpha(hexString: "#FFFFFF", alpha: 1.0)
        ]
        let backgroundImage = UIImage(gradientColors: colors, style: .vertical)
        self.backgroundImageView.image = backgroundImage
        self.backButton.setBackgroundColor(.white, for: .normal)
        
        self.tableView.register(cellType: GXPtActivityOrderCell.self)
        self.tableView.register(cellType: GXPtActivityPaySuccQRCodeCell.self)
        self.tableView.reloadData()
    }

}

extension GXPtActivityPaySuccVC {
    func requestGetSelectByOrderSn() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetSelectByOrderSn(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.gx_reloadData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXPtActivityPaySuccVC {
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension GXPtActivityPaySuccVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: GXPtActivityOrderCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindModel(data: self.infoData, totalPrice: self.viewModel.data?.totalPrice, isHiddenLocation: false)
            cell.locationAction = {[weak self] in
                guard let `self` = self else { return }
                guard let data = self.viewModel.data else { return }
//                let vc = GXActivityMapVC(data: data)
//                self.navigationController?.pushViewController(vc, animated: true)
                let coordinate = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
                XYNavigationManager.show(with: self, coordinate: coordinate, endAddress: data.address)
            }
            return cell
        }
        let cell: GXPtActivityPaySuccQRCodeCell = tableView.dequeueReusableCell(for: indexPath)
        if let detailData = self.viewModel.data {
            cell.bindCell(model: detailData)
        } else {
            cell.bindCell(model: self.signData)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100.0
        }
        return .zero
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        }
        return 130.0 + (tableView.width - 160.0)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
    }
}

