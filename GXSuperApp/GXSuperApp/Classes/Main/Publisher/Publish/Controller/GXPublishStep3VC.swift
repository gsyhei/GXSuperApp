//
//  GXPublishStep1VC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/30.
//

import UIKit
import RxCocoa
import RxCocoaPlus
import MBProgressHUD

class GXPublishStep3VC: GXBaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    /// 活动要求
    @IBOutlet weak var activityDressCodeTV: GXTextView!
    @IBOutlet weak var activityDressCodeNumLabel: UILabel!
    /// 活动福利-普通用户福利
    @IBOutlet weak var activityUserWealTV: GXTextView!
    @IBOutlet weak var activityUserWealNumLabel: UILabel!
    /// 活动福利-VIP用户福利
    @IBOutlet weak var activityVipWealTV: GXTextView!
    @IBOutlet weak var activityVipWealNumLabel: UILabel!
    /// 底部栏
    @IBOutlet weak var activitySaveDraftBtn: UIButton!
    @IBOutlet weak var activityLastBtn: UIButton!
    @IBOutlet weak var activityNextBtn: UIButton!

    weak var viewModel: GXPublishStepViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "发布活动"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.activitySaveDraftBtn.setBackgroundColor(.white, for: .normal)
        self.activityLastBtn.setBackgroundColor(.gx_lightPublicGreen, for: .normal)
        self.activityNextBtn.setBackgroundColor(.gx_green, for: .normal)

        self.activityDressCodeTV.placeholder = "选填"
        self.activityUserWealTV.placeholder = "选填，例如：现场吧台赠送一杯咖啡"
        self.activityVipWealTV.placeholder = "选填，例如：现场吧台赠送精美礼品一份"

        self.activityDressCodeTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.activityDressCodeTV.markedTextRange == nil else { return }
            guard var text = self.activityDressCodeTV.text else { return }
            let maxCount: Int = 500
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.activityDressCodeTV.text = text
            }
            self.activityDressCodeNumLabel.text = "\(text.count)/\(maxCount)"
            self.activityDressCodeNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        self.activityUserWealTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.activityUserWealTV.markedTextRange == nil else { return }
            guard var text = self.activityUserWealTV.text else { return }
            let maxCount: Int = 500
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.activityUserWealTV.text = text
            }
            self.activityUserWealNumLabel.text = "\(text.count)/\(maxCount)"
            self.activityUserWealNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        self.activityVipWealTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.activityVipWealTV.markedTextRange == nil else { return }
            guard var text = self.activityVipWealTV.text else { return }
            let maxCount: Int = 500
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.activityVipWealTV.text = text
            }
            self.activityVipWealNumLabel.text = "\(text.count)/\(maxCount)"
            self.activityVipWealNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        // Bind input
        (self.activityDressCodeTV.rx.textInput <-> self.viewModel.activityDressCodeInput).disposed(by: disposeBag)
        (self.activityUserWealTV.rx.textInput <-> self.viewModel.activityUserWealInput).disposed(by: disposeBag)
        (self.activityVipWealTV.rx.textInput <-> self.viewModel.activityVipWealInput).disposed(by: disposeBag)
    }
}

private extension GXPublishStep3VC {

    /// 保存草稿
    func requestSaveActivityDraft() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestAllSaveActivityDraft(step: 4, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showSuccess(text: "保存成功", to: self?.view)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXPublishStep3VC {

    /// 保存草稿
    @IBAction func activitySaveDraftBtnClicked(_ sender: UIButton) {
        self.requestSaveActivityDraft()
    }
    /// 上一步
    @IBAction func activityLastBtnClicked(_ sender: UIButton) {
        self.backBarButtonItemTapped()
    }
    /// 下一步
    @IBAction func activityNextBtnClicked(_ sender: UIButton) {
        let vc = GXPublishStep4VC.xibViewController().then {
            $0.viewModel = self.viewModel
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
