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
import XCGLogger

class GXPublishStep2VC: GXBaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    /// 活动参与人数-不限制
    @IBOutlet weak var activityNumberOfPeopleNoBtn: UIButton!
    /// 活动参与人数-限制
    @IBOutlet weak var activityNumberOfPeopleYesBtn: UIButton!
    /// 活动参与人数-输入
    @IBOutlet weak var activityNumberOfPeopleTF: UITextField!
    /// 活动参与人数-仅VIP可报名
    @IBOutlet weak var activityVipCanSignUpBtn: UIButton!
    /// 活动模式及价格-规则说明
    @IBOutlet weak var activityModeRuleDescBtn: UIButton!
    /// 活动模式及价格-免费报名模式
    @IBOutlet weak var activityModeFreeSignUpBtn: UIButton!
    @IBOutlet weak var activityModeFreeSignUpContentView: UIView!
    @IBOutlet weak var activityModeFreeSignUpHLC: NSLayoutConstraint!
    /// 活动模式及价格-卖票模式
    @IBOutlet weak var activityModeSellTicketsBtn: UIButton!
    @IBOutlet weak var activityModeSellTicketsContentView: UIView!
    @IBOutlet weak var activityModeSellTicketsHLC: NSLayoutConstraint!

    /// 免费-报名开始日期
    @IBOutlet weak var activitySPFreeSignUpStartDateBtn: UIButton!
    /// 免费-报名结束日期
    @IBOutlet weak var activitySPFreeSignUpEndDateBtn: UIButton!

    /// 标准价-普通用户
    @IBOutlet weak var activityStandardPriceUserTF: UITextField!
    /// 标准价-VIP用户
    @IBOutlet weak var activityStandardPriceVipTF: UITextField!
    /// 标准价-报名开始日期
    @IBOutlet weak var activitySPSignUpStartDateBtn: UIButton!
    /// 标准价-报名结束日期
    @IBOutlet weak var activitySPSignUpEndDateBtn: UIButton!

    /// 早鸟价选框
    @IBOutlet weak var activityPreferentialCheckBtn: UIButton!
    /// 早鸟价区域高度
    @IBOutlet weak var activityPreferentialHLC: NSLayoutConstraint!
    /// 早鸟价-普通用户
    @IBOutlet weak var activityPreferentialPriceUserTF: UITextField!
    /// 早鸟价-VIP用户
    @IBOutlet weak var activityPreferentialPriceVipTF: UITextField!
    /// 早鸟价-报名开始日期
    @IBOutlet weak var activityPPSignUpStartDateBtn: UIButton!
    /// 早鸟价-报名结束日期
    @IBOutlet weak var activityPPSignUpEndDateBtn: UIButton!

    /// 底部栏
    @IBOutlet weak var activitySaveDraftBtn: UIButton!
    @IBOutlet weak var activityLastBtn: UIButton!
    @IBOutlet weak var activityNextBtn: UIButton!

    private var symbolLabel: UILabel {
        return UILabel().then {
            $0.frame = CGRect(x: 0, y: 0, width: 30, height: 40)
            $0.textAlignment = .right
            $0.textColor = .gx_drakGray
            $0.text = " ￥"
            $0.font = .gx_font(size: 15)
        }
    }

    weak var viewModel: GXPublishStepViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "发布活动"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.activitySPSignUpStartDateBtn.setBackgroundColor(.gx_background, for: .normal)
        self.activitySPSignUpStartDateBtn.setBackgroundColor(.gx_lightGray1, for: .disabled)
        self.activitySPSignUpEndDateBtn.setBackgroundColor(.gx_background, for: .normal)
        self.activityPPSignUpStartDateBtn.setBackgroundColor(.gx_background, for: .normal)
        self.activityPPSignUpEndDateBtn.setBackgroundColor(.gx_background, for: .normal)
        self.activitySaveDraftBtn.setBackgroundColor(.white, for: .normal)
        self.activityLastBtn.setBackgroundColor(.gx_lightPublicGreen, for: .normal)
        self.activityNextBtn.setBackgroundColor(.gx_green, for: .normal)

        self.activityStandardPriceUserTF.leftView = self.symbolLabel
        self.activityStandardPriceUserTF.leftViewMode = .always
        self.activityStandardPriceVipTF.leftView = self.symbolLabel
        self.activityStandardPriceVipTF.leftViewMode = .always
        self.activityPreferentialPriceUserTF.leftView = self.symbolLabel
        self.activityPreferentialPriceUserTF.leftViewMode = .always
        self.activityPreferentialPriceVipTF.leftView = self.symbolLabel
        self.activityPreferentialPriceVipTF.leftViewMode = .always

        // Bind input
        (self.activityNumberOfPeopleTF.rx.textInput <-> self.viewModel.activityNumberOfPeopleInput).disposed(by: disposeBag)
        (self.activityStandardPriceUserTF.rx.textInput <-> self.viewModel.activityStandardPriceUserInput).disposed(by: disposeBag)
        (self.activityStandardPriceVipTF.rx.textInput <-> self.viewModel.activityStandardPriceVipInput).disposed(by: disposeBag)
        (self.activityPreferentialPriceUserTF.rx.textInput <-> self.viewModel.activityPreferentialPriceUserInput).disposed(by: disposeBag)
        (self.activityPreferentialPriceVipTF.rx.textInput <-> self.viewModel.activityPreferentialPriceVipInput).disposed(by: disposeBag)
        
        // 改变底栏按钮
        if self.viewModel.publishEditType == .detail {
            self.activitySaveDraftBtn.setBackgroundColor(.gx_green, for: .normal)
            self.activitySaveDraftBtn.setTitle("上一步", for: .normal)
            self.activityLastBtn.setTitle("下一步", for: .normal)
            self.activityNextBtn.setTitle("提交", for: .normal)
        }

        // 限制人数输入
        self.activityNumberOfPeopleTF.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard var number = Int(string) else { return }
            if number == 0 {
                self.activityNumberOfPeopleTF.text = nil
            }
            else if number > 9999 {
                number = 9999
                self.activityNumberOfPeopleTF.text = String(number)
            }
            XCGLogger.info("activityNumberOfPeopleTF: \(String(describing: self.viewModel.activityNumberOfPeopleInput.value))")
        }).disposed(by: disposeBag)

        self.updateInfoInput()
    }
}

extension GXPublishStep2VC {
    /// 活动参与人数-不限制
    @IBAction func activityNumberOfPeopleNoBtnClicked(_ sender: UIButton) {
        self.setActivityNumberOfPeopleChecked(check: false)
    }
    /// 活动参与人数-限制
    @IBAction func activityNumberOfPeopleYesBtnClicked(_ sender: UIButton) {
        self.setActivityNumberOfPeopleChecked(check: true)
    }
    /// 活动参与人数-仅VIP可报名
    @IBAction func activityVipCanSignUpBtnClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.viewModel.activityVipCanSignUpChecked = sender.isSelected
    }
    /// 活动模式及价格-规则说明
    @IBAction func activityModeRuleDescBtnClicked(_ sender: UIButton) {
        let vc = GXPublishRuleDescVC.xibViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /// 活动模式及价格-免费报名模式
    @IBAction func activityModeFreeSignUpBtnClicked(_ sender: UIButton) {
        self.setActivitySignUpMode(mode: 1)
    }
    /// 活动模式及价格-卖票模式
    @IBAction func activityModeSellTicketsBtnClicked(_ sender: UIButton) {
        self.setActivitySignUpMode(mode: 2)
    }
    /// 早鸟价选择
    @IBAction func activityPreferentialCheckBtnClicked(_ sender: UIButton) {
        self.setActivityPreferentialChecked(!sender.isSelected)
    }

    /// 免费-报名开始日期
    @IBAction func activitySPFreeSignUpStartDateBtnClicked(_ sender: UIButton) {
        let pickerDateView: GXDatePickerView = {
            return GXDatePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 560)
                var maxSelectDate = self.viewModel.activityEndDate
                if let signUpEndDate = self.viewModel.activitySPFreeSignUpEndDate {
                    let systemDate = GXServiceManager.shared.systemDate
                    let differenceDay = Calendar.current.dateComponents([.day], from: signUpEndDate, to: systemDate).day ?? 0
                    if differenceDay <= 0 {
                        maxSelectDate = signUpEndDate
                    }
                }
                $0.setSelectedDate(
                    self.viewModel.activitySPFreeSignUpStartDate,
                    maxSelectDate: maxSelectDate
                )
                $0.completion = {[weak self] date in
                    self?.viewModel.activitySPFreeSignUpStartDate = date
                    self?.activitySPFreeSignUpStartDateBtn.setTitle(date.string(format: "yyyy年MM月dd日"), for: .normal)
                }
            }
        }()
        pickerDateView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
    /// 免费-报名结束日期
    @IBAction func activitySPFreeSignUpEndDateBtnClicked(_ sender: UIButton) {
        let pickerDateView: GXDatePickerView = {
            return GXDatePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 560)
                $0.setSelectedDate(
                    self.viewModel.activitySPFreeSignUpEndDate,
                    minSelectDate: self.viewModel.activitySPFreeSignUpStartDate,
                    maxSelectDate: self.viewModel.activityEndDate
                )
                $0.completion = {[weak self] date in
                    self?.viewModel.activitySPFreeSignUpEndDate = date
                    self?.activitySPFreeSignUpEndDateBtn.setTitle(date.string(format: "yyyy年MM月dd日"), for: .normal)
                }
            }
        }()
        pickerDateView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
    /// 标准价-报名开始日期
    @IBAction func activitySPSignUpStartDateBtnClicked(_ sender: UIButton) {
        let pickerDateView: GXDatePickerView = {
            return GXDatePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 560)
                var maxSelectDate = self.viewModel.activityEndDate
                if let signUpEndDate = self.viewModel.activitySPSignUpEndDate {
                    let systemDate = GXServiceManager.shared.systemDate
                    let differenceDay = Calendar.current.dateComponents([.day], from: signUpEndDate, to: systemDate).day ?? 0
                    if differenceDay <= 0 {
                        maxSelectDate = signUpEndDate
                    }
                }
                $0.setSelectedDate(
                    self.viewModel.activitySPSignUpStartDate,
                    maxSelectDate: maxSelectDate
                )
                $0.completion = {[weak self] date in
                    self?.viewModel.activitySPSignUpStartDate = date
                    self?.activitySPSignUpStartDateBtn.setTitle(date.string(format: "yyyy年MM月dd日"), for: .normal)
                }
            }
        }()
        pickerDateView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
    /// 标准价-报名结束日期
    @IBAction func activitySPSignUpEndDateBtnClicked(_ sender: UIButton) {
        let pickerDateView: GXDatePickerView = {
            return GXDatePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 560)
                $0.setSelectedDate(
                    self.viewModel.activitySPSignUpEndDate,
                    minSelectDate: self.viewModel.activitySPSignUpStartDate,
                    maxSelectDate: self.viewModel.activityEndDate
                )
                $0.completion = {[weak self] date in
                    self?.viewModel.activitySPSignUpEndDate = date
                    self?.activitySPSignUpEndDateBtn.setTitle(date.string(format: "yyyy年MM月dd日"), for: .normal)
                }
            }
        }()
        pickerDateView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
    /// 早鸟价-报名开始日期
    @IBAction func activityPPSignUpStartDateBtnClicked(_ sender: UIButton) {
        let pickerDateView: GXDatePickerView = {
            return GXDatePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 560)
                var maxSelectDate = self.viewModel.activityEndDate
                if let signUpEndDate = self.viewModel.activityPPSignUpEndDate {
                    let systemDate = GXServiceManager.shared.systemDate
                    let differenceDay = Calendar.current.dateComponents([.day], from: signUpEndDate, to: systemDate).day ?? 0
                    if differenceDay <= 0 {
                        maxSelectDate = signUpEndDate
                    }
                }
                $0.setSelectedDate(
                    self.viewModel.activityPPSignUpStartDate,
                    maxSelectDate: maxSelectDate
                )
                $0.completion = {[weak self] date in
                    self?.viewModel.activityPPSignUpStartDate = date
                    self?.activityPPSignUpStartDateBtn.setTitle(date.string(format: "yyyy年MM月dd日"), for: .normal)
                }
            }
        }()
        pickerDateView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
    /// 早鸟价-报名结束日期
    @IBAction func activityPPSignUpEndDateBtnClicked(_ sender: UIButton) {
        let pickerDateView: GXDatePickerView = {
            return GXDatePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 560)
                var maxSelectDate: Date?
                if let endDate = self.viewModel.activityEndDate {
                    maxSelectDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)
                }
                $0.setSelectedDate(
                    self.viewModel.activityPPSignUpEndDate,
                    minSelectDate: self.viewModel.activityPPSignUpStartDate,
                    maxSelectDate: maxSelectDate
                )
                $0.completion = {[weak self] date in
                    self?.viewModel.activityPPSignUpEndDate = date
                    self?.activityPPSignUpEndDateBtn.setTitle(date.string(format: "yyyy年MM月dd日"), for: .normal)

                    let spSignBeginDate = Calendar.current.date(byAdding: .day, value: 1, to: date)
                    self?.viewModel.activitySPSignUpStartDate = spSignBeginDate
                    self?.activitySPSignUpStartDateBtn.setTitle(spSignBeginDate?.string(format: "yyyy年MM月dd日"), for: .normal)
                    self?.activitySPSignUpStartDateBtn.isEnabled = false
                }
            }
        }()
        pickerDateView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
    /// 保存草稿
    @IBAction func activitySaveDraftBtnClicked(_ sender: UIButton) {
        if self.viewModel.publishEditType == .detail {
            // 上一步
            self.backBarButtonItemTapped()
        }
        else {
            // 保存草稿
            self.requestSaveActivityDraft()
        }
    }
    /// 上一步
    @IBAction func activityLastBtnClicked(_ sender: UIButton) {
        if self.viewModel.publishEditType == .detail {
            // 详情编辑时为下一步
            let checked = self.viewModel.isEditBaseInfoPage2Checked()
            guard checked else { return }
            
            let vc = GXPublishStep4VC.xibViewController().then {
                $0.viewModel = self.viewModel
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            // 上一步
            self.backBarButtonItemTapped()
        }
    }
    /// 下一步
    @IBAction func activityNextBtnClicked(_ sender: UIButton) {
        let checked = self.viewModel.isEditBaseInfoPage2Checked()
        guard checked else { return }

        if self.viewModel.publishEditType == .detail {
            // 详情编辑时为提交（修改基本资料）
            self.requestEditActivity()
        }
        else {
            // 下一步
            let vc = GXPublishStep3VC.xibViewController().then {
                $0.viewModel = self.viewModel
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

extension GXPublishStep2VC {
    /// 设置编辑内容
    func updateInfoInput() {
        /// 活动参与人数-是否限制
        self.setActivityNumberOfPeopleChecked(check: self.viewModel.activityNumberOfPeopleChecked)
        /// 活动参与人数-仅VIP可报名
        self.activityVipCanSignUpBtn.isSelected = self.viewModel.activityVipCanSignUpChecked
        /// 活动模式及价格-报名模式
        self.setActivitySignUpMode(mode: self.viewModel.activitySignUpMode)
        /// 早鸟价选择设置
        self.setActivityPreferentialChecked(self.viewModel.activityPreferentialChecked)
        /// 免费-报名开始日期
        self.activitySPFreeSignUpStartDateBtn.setTitle(self.viewModel.activitySPFreeSignUpStartDate?.string(format: "yyyy年MM月dd日") ?? "--", for: .normal)
        /// 免费-报名结束日期
        self.activitySPFreeSignUpEndDateBtn.setTitle(self.viewModel.activitySPFreeSignUpEndDate?.string(format: "yyyy年MM月dd日") ?? "--", for: .normal)
        /// 标准价-报名开始日期
        self.activitySPSignUpStartDateBtn.setTitle(self.viewModel.activitySPSignUpStartDate?.string(format: "yyyy年MM月dd日") ?? "--", for: .normal)
        /// 标准价-报名结束日期
        self.activitySPSignUpEndDateBtn.setTitle(self.viewModel.activitySPSignUpEndDate?.string(format: "yyyy年MM月dd日") ?? "--", for: .normal)
        /// 早鸟价-报名开始日期
        self.activityPPSignUpStartDateBtn.setTitle(self.viewModel.activityPPSignUpStartDate?.string(format: "yyyy年MM月dd日") ?? "--", for: .normal)
        /// 早鸟价-报名结束日期
        self.activityPPSignUpEndDateBtn.setTitle(self.viewModel.activityPPSignUpEndDate?.string(format: "yyyy年MM月dd日") ?? "--", for: .normal)
    }
    /// 活动参与人数-是否限制
    func setActivityNumberOfPeopleChecked(check: Bool) {
        if check {
            self.activityNumberOfPeopleNoBtn.isSelected = false
            self.activityNumberOfPeopleYesBtn.isSelected = true
        }
        else {
            self.activityNumberOfPeopleNoBtn.isSelected = true
            self.activityNumberOfPeopleYesBtn.isSelected = false
        }
        self.viewModel.activityNumberOfPeopleChecked = check
    }
    /// 活动模式及价格-免费报名模式(1-免费报名模式 2-卖票模式)
    func setActivitySignUpMode(mode: Int) {
        if mode == 1 {
            self.activityModeFreeSignUpBtn.isSelected = true
            self.activityModeSellTicketsBtn.isSelected = false
            self.viewModel.activitySignUpMode = 1
            self.activityModeFreeSignUpContentView.isHidden = false
            self.activityModeFreeSignUpHLC.constant = 88.0
            self.activityModeSellTicketsContentView.isHidden = true
            self.activityModeSellTicketsHLC.constant = 0.0
        }
        else {
            self.activityModeFreeSignUpBtn.isSelected = false
            self.activityModeSellTicketsBtn.isSelected = true
            self.viewModel.activitySignUpMode = 2
            self.activityModeFreeSignUpContentView.isHidden = true
            self.activityModeFreeSignUpHLC.constant = 0.0
            self.activityModeSellTicketsContentView.isHidden = false
            self.activityModeSellTicketsHLC.constant = 404.0
        }
        if (self.viewModel.infoData?.signedNum ?? 0) > 0 {
            self.activityModeFreeSignUpBtn.isUserInteractionEnabled = false
            self.activityModeSellTicketsBtn.isUserInteractionEnabled = false
        }
    }
    /// 早鸟价选择设置
    func setActivityPreferentialChecked(_ checked: Bool) {
        self.activityPreferentialCheckBtn.isSelected = checked
        self.viewModel.activityPreferentialChecked = checked
        if self.viewModel.activityPreferentialChecked {
            self.activityPreferentialHLC.constant = 192.0
            if let date = self.viewModel.activityPPSignUpEndDate {
                let spSignBeginDate = Calendar.current.date(byAdding: .day, value: 1, to: date)
                self.viewModel.activitySPSignUpStartDate = spSignBeginDate
                self.activitySPSignUpStartDateBtn.setTitle(spSignBeginDate?.string(format: "yyyy年MM月dd日"), for: .normal)
                self.activitySPSignUpStartDateBtn.isEnabled = false
            }
            else {
                self.activitySPSignUpStartDateBtn.isEnabled = true
            }
        } else {
            self.activitySPSignUpStartDateBtn.isEnabled = true
            self.activityPreferentialHLC.constant = 41.0
        }
    }
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
    /// 编辑提交审核
    func requestEditActivity() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestEditActivity(to: self, step: 2, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.showEditSuccessAlert()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
    func showEditSuccessAlert() {
        let title = "提交成功\n平台会在1-2个工作日内审核\n请耐心等待！"
        GXUtil.showAlert(title: title, cancelTitle: "我知道了") { alert, index in
            self.navigationController?.popToViewController(vcType: GXPublishActivityDetailVC.self, animated: true)
        }
    }

}
