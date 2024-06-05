//
//  GXMinePtRealNameVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/29.
//

import UIKit
import RxCocoa
import RxCocoaPlus
import MBProgressHUD

class GXMinePtRealNameVC: GXBaseViewController {
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var realNameTF: UITextField!
    @IBOutlet weak var idNumberTF: UITextField!

    var realnameFlag: Int = 0
    var realName = BehaviorRelay<String?>(value: nil)
    var idNumber = BehaviorRelay<String?>(value: nil)
    var completion: GXActionBlockItem<UIViewController?>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetRealName()
    }

    override func setupViewController() {
        self.title = "实名认证"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.realnameFlag = GXUserManager.shared.user?.realnameFlag ?? 0
        self.saveButton.setTitle("保存", for: .normal)
        self.saveButton.setBackgroundColor(.gx_green, for: .normal)
        self.saveButton.setTitle("已实名认证", for: .disabled)
        self.saveButton.setBackgroundColor(.gx_lightGray, for: .disabled)
        self.saveButton.isEnabled = self.realnameFlag == 0
        self.view.isUserInteractionEnabled = self.realnameFlag == 0
        self.idNumberTF.autocorrectionType = .no

        (self.realNameTF.rx.textInput <-> self.realName).disposed(by: disposeBag)
        (self.idNumberTF.rx.textInput <-> self.idNumber).disposed(by: disposeBag)
        
        self.realNameTF.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.realNameTF.markedTextRange == nil else { return }
            guard var text = self.realNameTF.text else { return }
            let maxCount: Int = 10
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.realNameTF.text = text
            }
        }).disposed(by: disposeBag)
        self.idNumberTF.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.idNumberTF.markedTextRange == nil else { return }
            guard var text = self.idNumberTF.text else { return }
            let maxCount: Int = 18
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.idNumberTF.text = text
            }
        }).disposed(by: disposeBag)
    }

    func requestGetRealName() {
        guard self.realnameFlag == 1 else { return }

        MBProgressHUD.showLoading(to: self.view)
        let params: Dictionary<String, Any> = [:]
        let api = GXApi.normalApi(Api_User_GetRealName, params, .get)
        GXNWProvider.login_request(api, type: GXGetRealNameModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.realName.accept(model.data?.realName)
            self.idNumber.accept(model.data?.idNo)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestRealNameAuth() {
        if self.realName.value?.count ?? 0 == 0 {
            GXToast.showError(text: self.realNameTF.placeholder, to: self.view)
            return
        }
        if self.idNumber.value?.count ?? 0 == 0 {
            GXToast.showError(text: self.idNumberTF.placeholder, to: self.view)
            return
        }
        MBProgressHUD.showLoading(to: self.view)
        var params: Dictionary<String, Any> = [:]
        params["idNo"] = self.idNumber.value
        params["realName"] = self.realName.value
        let api = GXApi.normalApi(Api_User_RealNameAuth, params, .post)
        GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            GXUserManager.shared.user?.realnameFlag = 1
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showSuccess(text: "认证成功")
            self.completion?(self)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXMinePtRealNameVC {
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        self.requestRealNameAuth()
    }
}
