//
//  GXMinePtEditPersonalVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/2/3.
//

import UIKit
import RxCocoa
import RxCocoaPlus
import MBProgressHUD

class GXMinePtEditPersonalVC: GXBaseViewController {
    /// 昵称
    @IBOutlet weak var infoTF: GXTextView!
    @IBOutlet weak var infoNumLabel: UILabel!
    /// 提交按钮
    @IBOutlet weak var submitButton: UIButton!

    weak var viewModel: GXMinePtEditInfoViewModel!
    var completion: GXActionBlock?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "编辑个人介绍"
        self.gx_addNavTopView(color: .white)
        self.gx_addBackBarButtonItem()

        self.submitButton.setBackgroundColor(.gx_green, for: .normal)
        self.submitButton.setBackgroundColor(.gx_lightGray, for: .disabled)
        self.submitButton.isEnabled = false

        self.infoTF.placeholder = "填写个人介绍"
        self.infoTF.rx.text.orEmpty.subscribe (onNext: {[weak self] text in
            guard let `self` = self else { return }
            guard self.infoTF.markedTextRange == nil else { return }
            self.submitButton.isEnabled = text.count > 0
            var text = text
            let maxCount: Int = 100
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.infoTF.text = text
            }
            self.infoNumLabel.text = "\(text.count)/\(maxCount)"
            self.infoNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)
        
        if let model = self.viewModel.personalModel {
            (self.infoTF.rx.textInput <-> model.detail).disposed(by: disposeBag)
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

extension GXMinePtEditPersonalVC {
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.viewModel.personalModel?.detail.value?.count ?? 0 == 0 {
            GXToast.showSuccess(text: "请输入个人介绍", to: self.view)
            return
        }
        self.requestEditUserInfo()
    }
}
