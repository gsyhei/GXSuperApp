//
//  GXPublishFinancialEditMaterialVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/23.
//

import UIKit
import HXPhotoPicker
import RxCocoaPlus
import MBProgressHUD

class GXPublishFinancialEditMaterialVC: GXBaseViewController {
    /// 问卷名称
    @IBOutlet weak var materialNameTV: GXTextView!
    @IBOutlet weak var materialNameNumLabel: UILabel!
    /// 数量
    @IBOutlet weak var materialNumberTF: UITextField!
    /// 单价
    @IBOutlet weak var unitPriceTF: UITextField!
    /// 小计
    @IBOutlet weak var totalPriceTF: UITextField!
    /// 保存
    @IBOutlet weak var saveButton: UIButton!

    private lazy var viewModel: GXPublishFinancialEditMaterialViewModel = {
        return GXPublishFinancialEditMaterialViewModel()
    }()

    class func createVC(activityData: GXActivityBaseInfoData, data: GXActivityfinancesListItem? = nil) -> GXPublishFinancialEditMaterialVC {
        return GXPublishFinancialEditMaterialVC.xibViewController().then {
            $0.viewModel.activityData = activityData
            $0.viewModel.data = data
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "添加物料"
        self.gx_addBackBarButtonItem()

        self.saveButton.setBackgroundColor(.gx_green, for: .normal)
        self.materialNameTV.placeholder = "输入物料名称"
        self.materialNameTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.materialNameTV.markedTextRange == nil else { return }
            guard var text = self.materialNameTV.text else { return }
            let maxCount: Int = 50
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.materialNameTV.text = text
            }
            self.materialNameNumLabel.text = "\(text.count)/\(maxCount)"
            self.materialNameNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        self.materialNumberTF.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard var number = Int(string) else { return }
            if number > 999999 {
                number = 999999
                self.materialNumberTF.text = String(number)
            }
            guard let unitPriceStr = self.viewModel.unitPrice.value else { return }
            guard let unitPrice = Float(unitPriceStr) else { return }
            let totalPrice: Float = unitPrice * Float(number)
            self.viewModel.totalPrice.accept(String(format: "%.2f", totalPrice))
        }).disposed(by: disposeBag)

        self.unitPriceTF.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.unitPriceTF.markedTextRange == nil else { return }
            var strArr = string.components(separatedBy: ".")
            if strArr.count == 2 {
                if strArr[1].count > 2 {
                    strArr[1] = strArr[1].substring(to: 2)
                }
            }
            let text: String = strArr.joined(separator: ".")
            self.unitPriceTF.text = text
            guard let unitPrice = Float(text) else { return }
            guard let numberStr = self.viewModel.materialNumber.value else { return }
            guard let number = Int(numberStr) else { return }
            let totalPrice: Float = unitPrice * Float(number)
            self.viewModel.totalPrice.accept(String(format: "%.2f", totalPrice))
        }).disposed(by: disposeBag)

        // Bind input
        (self.materialNameTV.rx.textInput <-> self.viewModel.materialName).disposed(by: disposeBag)
        (self.materialNumberTF.rx.textInput <-> self.viewModel.materialNumber).disposed(by: disposeBag)
        (self.unitPriceTF.rx.textInput <-> self.viewModel.unitPrice).disposed(by: disposeBag)
        (self.totalPriceTF.rx.textInput <-> self.viewModel.totalPrice).disposed(by: disposeBag)
    }

}

extension GXPublishFinancialEditMaterialVC {
    func requestSaveFinance() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestSaveFinance(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showSuccess(text: "保存成功")
            self.gx_backBarButtonItemTapped()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXPublishFinancialEditMaterialVC {

    @IBAction func saveButtonClicked(_ sender: UIButton) {
        if (self.viewModel.materialName.value ?? "").isEmpty {
            GXToast.showError(text: "请输入物料名称", to: self.view)
            return
        }
        self.requestSaveFinance()
    }

}
