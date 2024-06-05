//
//  GXMinePtOrderDetailVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/1.
//

import UIKit
import MBProgressHUD
import XCGLogger

class GXMinePtOrderDetailVC: GXBaseViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tableView: GXBaseTableView!

    private var viewModel: GXMinePtOrderDetailViewModel = {
        return GXMinePtOrderDetailViewModel()
    }()

    class func createVC(orderSn: String) -> GXMinePtOrderDetailVC {
        return GXMinePtOrderDetailVC.xibViewController().then {
            $0.viewModel.orderSn = orderSn
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetSelectByOrderSn()
    }

    override func setupViewController() {
        self.title = "订单详情"
        self.gx_addBackBarButtonItem()

        let colors: [UIColor] = [
            .hexWithAlpha(hexString: "#80FBAD", alpha: 1.0),
            .hexWithAlpha(hexString: "#FFFFFF", alpha: 1.0)
        ]
        let backgroundImage = UIImage(gradientColors: colors, style: .vertical)
        self.backgroundImageView.image = backgroundImage
        
        self.tableView.placeholder = nil
        self.tableView.separatorColor = .gx_lightGray
        self.tableView.register(cellType: GXPtActivityOrderCell.self)
        self.tableView.register(cellType: GXMinePtOrderDetailCell.self)
        self.tableView.register(cellType: GXPtActivityPaySuccQRCodeCell.self)
        self.tableView.reloadData()
    }

}

extension GXMinePtOrderDetailVC {
    func requestGetSelectByOrderSn() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetSelectByOrderSn(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.reloadData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXMinePtOrderDetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.data == nil { return 0 }

        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: GXPtActivityOrderCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.data)
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
        else if indexPath.row == 1 {
            let cell: GXMinePtOrderDetailCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.data)
            return cell
        }
        let cell: GXPtActivityPaySuccQRCodeCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bindCell(model: self.viewModel.data)

        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < 2 {
            return 120.0
        }
        return .zero
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < 2 {
            return UITableView.automaticDimension
        }
        return 130.0 + (tableView.width - 160.0)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
    }
}

