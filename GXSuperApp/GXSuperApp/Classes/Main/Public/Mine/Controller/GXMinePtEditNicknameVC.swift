//
//  GXMinePtEditNicknameVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/2/3.
//

import UIKit
import RxCocoa
import RxCocoaPlus
import MBProgressHUD

class GXMinePtEditNicknameVC: GXBaseViewController {
    /// 昵称
    @IBOutlet weak var nicknameTF: UITextField!
    @IBOutlet weak var nicknameNumLabel: UILabel!
    /// 提交按钮
    @IBOutlet weak var submitButton: UIButton!

    weak var viewModel: GXMinePtEditInfoViewModel!
    var completion: GXActionBlock?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "编辑昵称"
        self.gx_addNavTopView(color: .white)
        self.gx_addBackBarButtonItem()

        self.submitButton.setBackgroundColor(.gx_green, for: .normal)
        self.submitButton.setBackgroundColor(.gx_lightGray, for: .disabled)
        self.submitButton.isEnabled = false

        let maxCount: Int = 30
        self.nicknameTF.rx.text.orEmpty.subscribe (onNext: {[weak self] text in
            guard let `self` = self else { return }
            guard self.nicknameTF.markedTextRange == nil else { return }
            self.submitButton.isEnabled = text.count > 0
            var text = text
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.nicknameTF.text = text
            }
            self.nicknameNumLabel.text = "\(text.count)/\(maxCount)"
            self.nicknameNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)
        
        if let model = self.viewModel.nicknameModel {
            (self.nicknameTF.rx.textInput <-> model.detail).disposed(by: disposeBag)
            let text = model.detail.value ?? ""
            self.submitButton.isEnabled = text.count > 0
            self.nicknameNumLabel.text = "\(text.count)/\(maxCount)"
            self.nicknameNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }
    }
    
    func requestEditUserInfo() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestEditUserInfo {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showSuccess(text: "保存成功")
            self.navigationController?.popViewController(animated: true)
            self.completion?()
        } failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        }
    }
}

extension GXMinePtEditNicknameVC {
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.viewModel.nicknameModel?.detail.value?.count ?? 0 == 0 {
            GXToast.showSuccess(text: "请输入昵称", to: self.view)
            return
        }
        self.requestEditUserInfo()
    }
}
