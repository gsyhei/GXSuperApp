//
//  GXMinePtAddressEditVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/29.
//

import UIKit
import RxCocoa
import RxCocoaPlus
import MBProgressHUD

class GXMinePtAddressEditVC: GXBaseViewController {
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var addressTV: GXTextView!
    @IBOutlet weak var addCodeTV: GXTextView!

    var nameBR = BehaviorRelay<String?>(value: nil)
    var phoneBR = BehaviorRelay<String?>(value: nil)
    var addressBR = BehaviorRelay<String?>(value: nil)
    var addCodeBR = BehaviorRelay<String?>(value: nil)
    var addressData: GXUserAddressPageItem?

    class func createVC(data: GXUserAddressPageItem? = nil) -> GXMinePtAddressEditVC {
        return GXMinePtAddressEditVC.xibViewController().then {
            $0.addressData = data?.gx_copy()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "添加地址"
        self.gx_addBackBarButtonItem()
        
        let placeholderColor = UIColor.hex(hexString: "#C1C1C1")
        let placeholderFont = UIFont.gx_font(size: 15)
        self.nameTF.gx_setPlaceholder(text: "请输入姓名",
                                      color: placeholderColor,
                                      font: placeholderFont)
        self.phoneTF.gx_setPlaceholder(text: "请填写11位手机号",
                                       color: placeholderColor,
                                       font: placeholderFont)
        self.addressTV.placeHolderLabel.textAlignment = .right
        self.addressTV.placeholder = "请输入省份、城市、区县"
        self.addressTV.placeholderColor = placeholderColor
        self.addressTV.font = placeholderFont
        self.addressTV.gx_setMarginZero()
        self.addCodeTV.placeHolderLabel.textAlignment = .right
        self.addCodeTV.placeholder = "如街道、小区、楼牌号等"
        self.addCodeTV.placeholderColor = placeholderColor
        self.addCodeTV.font = placeholderFont
        self.addCodeTV.gx_setMarginZero()
        self.saveButton.setBackgroundColor(.gx_green, for: .normal)

        self.nameTF.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.nameTF.markedTextRange == nil else { return }
            guard var text = self.nameTF.text else { return }
            let maxCount: Int = 30
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.nameTF.text = text
            }
        }).disposed(by: disposeBag)
        self.phoneTF.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.phoneTF.markedTextRange == nil else { return }
            guard var text = self.phoneTF.text else { return }
            let maxCount: Int = 11
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.phoneTF.text = text
            }
        }).disposed(by: disposeBag)
        self.addressTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.addressTV.markedTextRange == nil else { return }
            guard var text = self.addressTV.text else { return }
            let maxCount: Int = 120
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.addressTV.text = text
            }
        }).disposed(by: disposeBag)
        self.addCodeTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.addCodeTV.markedTextRange == nil else { return }
            guard var text = self.addCodeTV.text else { return }
            let maxCount: Int = 120
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.addCodeTV.text = text
            }
        }).disposed(by: disposeBag)

        (self.nameTF.rx.textInput <-> self.nameBR).disposed(by: disposeBag)
        (self.phoneTF.rx.textInput <-> self.phoneBR).disposed(by: disposeBag)
        (self.addressTV.rx.textInput <-> self.addressBR).disposed(by: disposeBag)
        (self.addCodeTV.rx.textInput <-> self.addCodeBR).disposed(by: disposeBag)

        if let data = self.addressData {
            self.nameBR.accept(data.consigneeName)
            self.phoneBR.accept(data.consigneePhone)
            self.addressBR.accept(data.consigneeAddress)
            self.addCodeBR.accept(data.detailedHouseNumber)
        }
    }

    func requestUpdateAddress() {
        if self.nameBR.value?.count ?? 0 == 0 {
            GXToast.showError(text: "姓名不能为空", to: self.view)
            return
        }
        if self.phoneBR.value?.count ?? 0 == 0 {
            GXToast.showError(text: "手机号不能为空", to: self.view)
            return
        }
        if self.addressBR.value?.count ?? 0 == 0 {
            GXToast.showError(text: "收货地区不能为空", to: self.view)
            return
        }
        if self.addCodeBR.value?.count ?? 0 == 0 {
            GXToast.showError(text: "详情地址不能为空", to: self.view)
            return
        }
        MBProgressHUD.showLoading(to: self.view)
        self.addressData?.consigneeName = self.nameBR.value ?? ""
        self.addressData?.consigneePhone = self.phoneBR.value ?? ""
        self.addressData?.consigneeAddress = self.addressBR.value ?? ""
        self.addressData?.detailedHouseNumber = self.addCodeBR.value ?? ""
        guard let params = self.addressData?.toJSON() else { return }
        let api = GXApi.normalApi(Api_CUserAddress_Update, params, .post)
        GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showSuccess(text: "保存成功")
            self.navigationController?.popViewController(animated: true)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestCreateAddress() {
        if self.nameBR.value?.count ?? 0 == 0 {
            GXToast.showError(text: "姓名不能为空", to: self.view)
            return
        }
        if self.phoneBR.value?.count ?? 0 == 0 {
            GXToast.showError(text: "手机号不能为空", to: self.view)
            return
        }
        if self.addressBR.value?.count ?? 0 == 0 {
            GXToast.showError(text: "收货地区不能为空", to: self.view)
            return
        }
        if self.addCodeBR.value?.count ?? 0 == 0 {
            GXToast.showError(text: "详情地址不能为空", to: self.view)
            return
        }
        MBProgressHUD.showLoading(to: self.view)
        var params: Dictionary<String, Any> = [:]
        params["consigneeName"] = self.nameBR.value
        params["consigneePhone"] = self.phoneBR.value
        params["consigneeAddress"] = self.addressBR.value
        params["detailedHouseNumber"] = self.addCodeBR.value
        
        let api = GXApi.normalApi(Api_CUserAddress_CreateAddress, params, .post)
        GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showSuccess(text: "保存成功")
            self.navigationController?.popViewController(animated: true)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXMinePtAddressEditVC {
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        if (self.addressData != nil) {
            self.requestUpdateAddress()
        }
        else {
            self.requestCreateAddress()
        }
    }
}
