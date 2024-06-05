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

class GXPublishStep1VC: GXBaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    /// 活动名称
    @IBOutlet weak var activityNameTV: GXTextView!
    @IBOutlet weak var activityNameNumLabel: UILabel!
    /// 活动类型容器
    @IBOutlet weak var activityTypeConView: GXActivityTypeListView!
    /// 活动类型容器高度
    @IBOutlet weak var activityTypeHeightLC: NSLayoutConstraint!
    /// 活动日期-开始日期
    @IBOutlet weak var activityStartDateBtn: UIButton!
    /// 活动日期-结束日期
    @IBOutlet weak var activityEndDateBtn: UIButton!
    /// 活动周期内每天-开始时间
    @IBOutlet weak var activityAllStartTimeBtn: UIButton!
    /// 活动周期内每天-结束时间
    @IBOutlet weak var activityAllEndTimeBtn: UIButton!
    /// 活动地址
    @IBOutlet weak var activityLocationBtn: UIButton!
    @IBOutlet weak var activityLocationLabel: UILabel!
    /// 位置描述
    @IBOutlet weak var activityLocationTV: GXTextView!
    @IBOutlet weak var activityLocationNumLabel: UILabel!
    /// 底部栏
    @IBOutlet weak var activitySaveDraftBtn: UIButton!
    @IBOutlet weak var activityNextBtn: UIButton!

    private lazy var viewModel: GXPublishStepViewModel = {
        return GXPublishStepViewModel()
    }()

    class func createVC(type: GXPublishStepViewModel.GXPublishEditType = .none,
                        activityId: Int? = nil,
                        infoData: GXActivityBaseInfoData? = nil,
                        picData: GXActivityPicInfoData? = nil) -> GXPublishStep1VC {
        return GXPublishStep1VC.xibViewController().then {
            $0.viewModel.publishEditType = type
            $0.viewModel.activityId = activityId
            $0.viewModel.infoData = infoData
            $0.viewModel.picData = picData
            $0.hidesBottomBarWhenPushed = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestActivityTypeList()
        self.requestActivityInfo()
    }

    override func setupViewController() {
        self.title = "发布活动"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.activityTypeConView.backgroundColor = .clear
        self.activityStartDateBtn.setBackgroundColor(.gx_background, for: .normal)
        self.activityEndDateBtn.setBackgroundColor(.gx_background, for: .normal)
        self.activityAllStartTimeBtn.setBackgroundColor(.gx_background, for: .normal)
        self.activityAllEndTimeBtn.setBackgroundColor(.gx_background, for: .normal)
        self.activityLocationBtn.setBackgroundColor(.gx_lightGray, for: .highlighted)
        self.activitySaveDraftBtn.setBackgroundColor(.white, for: .normal)
        self.activityNextBtn.setBackgroundColor(.gx_green, for: .normal)

        self.activityNameTV.placeholder = "描述一下活动的亮点、内容、推荐人群"
        self.activityLocationTV.placeholder = "请输入场馆名称"

        self.activityNameTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.activityNameTV.markedTextRange == nil else { return }
            guard var text = self.activityNameTV.text else { return }
            let maxCount: Int = 50
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.activityNameTV.text = text
            }
            self.activityNameNumLabel.text = "\(text.count)/\(maxCount)"
            self.activityNameNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        self.activityLocationTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.activityLocationTV.markedTextRange == nil else { return }
            guard var text = self.activityLocationTV.text else { return }
            let maxCount: Int = 50
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.activityLocationTV.text = text
            }
            self.activityLocationNumLabel.text = "\(text.count)/\(maxCount)"
            self.activityLocationNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        self.activityTypeConView.selectedAction = {[weak self] typeId in
            self?.viewModel.activityTypeId = typeId
        }

        self.activityAllStartTimeBtn.setTitle(self.viewModel.activityAllStartTime, for: .normal)
        self.activityAllEndTimeBtn.setTitle(self.viewModel.activityAllEndTime, for: .normal)
        
        // Bind input
        (self.activityNameTV.rx.textInput <-> self.viewModel.activityName).disposed(by: disposeBag)
        (self.activityLocationTV.rx.textInput <-> self.viewModel.activityLocationDesc).disposed(by: disposeBag)

        // 改变底栏按钮
        if self.viewModel.publishEditType == .detail {
            self.activitySaveDraftBtn.setBackgroundColor(.gx_green, for: .normal)
            self.activitySaveDraftBtn.setTitle("下一步", for: .normal)
            self.activityNextBtn.setTitle("提交", for: .normal)
        }
    }
}

private extension GXPublishStep1VC {
    func requestActivityTypeList() {
        self.viewModel.requestActivityTypeList {[weak self] in
            self?.updateActivityType()
        } failure: { error in
        }
    }

    func requestSaveActivityDraft() {
        if self.viewModel.activityName.value?.count == 0 {
            GXToast.showError(text: "请输入活动名称！")
            return
        }
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
        self.viewModel.requestEditActivity(to: self, step: 1, success: {[weak self] in
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

    func updateActivityType() {
        /// 活动类型容器
        let height = self.activityTypeConView.updateList(list: self.viewModel.activityTypeList, typeId: self.viewModel.activityTypeId)
        self.activityTypeHeightLC.constant = height
    }

    func requestActivityInfo() {
        guard self.viewModel.publishEditType != .none else { return }
        
        MBProgressHUD.showLoading(to: self.view)
        if self.viewModel.infoData == nil && self.viewModel.picData == nil {
            self.viewModel.requestGetActivityAllInfo {[weak self] in
                MBProgressHUD.dismiss(for: self?.view)
                self?.updateInfoInput()
            } failure: {[weak self] error in
                MBProgressHUD.dismiss(for: self?.view)
                GXToast.showError(error, to: self?.view)
            }
        }
        else if self.viewModel.infoData == nil {
            self.viewModel.requestGetActivityBaseInfo {[weak self] in
                MBProgressHUD.dismiss(for: self?.view)
                self?.updateInfoInput()
            } failure: {[weak self] error in
                MBProgressHUD.dismiss(for: self?.view)
                GXToast.showError(error, to: self?.view)
            }
        }
        else if self.viewModel.picData == nil {
            self.viewModel.requestGetActivityPicInfo {[weak self] in
                MBProgressHUD.dismiss(for: self?.view)
                self?.updateInfoInput()
            } failure: {[weak self] error in
                MBProgressHUD.dismiss(for: self?.view)
                GXToast.showError(error, to: self?.view)
            }
        }
        else {
            MBProgressHUD.dismiss(for: self.view)
            self.viewModel.updateInfoInput()
            self.updateInfoInput()
        }
    }

    func updateInfoInput() {
        /// 活动类型容器
        self.activityTypeConView.setSelected(typeId: self.viewModel.activityTypeId)
        /// 活动日期-开始日期
        self.activityStartDateBtn.setTitle(self.viewModel.activityStartDate?.string(format: "yyyy年MM月dd日") ?? "--", for: .normal)
        /// 活动日期-结束日期
        self.activityEndDateBtn.setTitle(self.viewModel.activityEndDate?.string(format: "yyyy年MM月dd日") ?? "--", for: .normal)
        /// 活动周期内每天-开始时间
        self.activityAllStartTimeBtn.setTitle(self.viewModel.activityAllStartTime, for: .normal)
        /// 活动周期内每天-结束时间
        self.activityAllEndTimeBtn.setTitle(self.viewModel.activityAllEndTime, for: .normal)
        /// 活动地址
        self.activityLocationLabel.text = (self.viewModel.activityLocation ?? "") + "\n" + (self.viewModel.activityCityName ?? "")
    }
}

extension GXPublishStep1VC {
    /// 活动日期-开始日期
    @IBAction func activityStartDateBtnClicked(_ sender: UIButton) {
        let pickerDateView: GXDatePickerView = {
            return GXDatePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 560)
                $0.setSelectedDate(self.viewModel.activityStartDate)
                $0.completion = {[weak self] date in
                    self?.viewModel.activityStartDate = date
                    self?.activityStartDateBtn.setTitle(date.string(format: "yyyy年MM月dd日"), for: .normal)
                }
            }
        }()
        pickerDateView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
    /// 活动日期-结束日期
    @IBAction func activityEndDateBtnClicked(_ sender: UIButton) {
        let pickerDateView: GXDatePickerView = {
            return GXDatePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 560)
                $0.setSelectedDate(self.viewModel.activityEndDate)
                $0.completion = {[weak self] date in
                    self?.viewModel.activityEndDate = date
                    self?.activityEndDateBtn.setTitle(date.string(format: "yyyy年MM月dd日"), for: .normal)
                }
            }
        }()
        pickerDateView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
    /// 活动周期内每天-开始时间
    @IBAction func activityAllStartTimeBtnClicked(_ sender: UIButton) {
        let pickerTimeView: GXTimePickerView = {
            return GXTimePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 360)
                $0.completion = {[weak self] time in
                    self?.viewModel.activityAllStartTime = time
                    self?.activityAllStartTimeBtn.setTitle(time, for: .normal)
                }
            }
        }()
        pickerTimeView.showSelectedTime(self.viewModel.activityAllStartTime)
        pickerTimeView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
    /// 活动周期内每天-结束时间
    @IBAction func activityAllEndTimeBtnClicked(_ sender: UIButton) {
        let pickerTimeView: GXTimePickerView = {
            return GXTimePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 360)
                $0.completion = {[weak self] time in
                    self?.viewModel.activityAllEndTime = time
                    self?.activityAllEndTimeBtn.setTitle(time, for: .normal)
                }
            }
        }()
        pickerTimeView.showSelectedTime(self.viewModel.activityAllEndTime)
        pickerTimeView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
    /// 活动地址
    @IBAction func activityLocationBtnClicked(_ sender: UIButton) {
        let vc = GXPublishLocationSearchVC.xibViewController()
        vc.selectedAction = {[weak self] (model, cityName, coordinate) in
            guard let `self` = self else { return }
            self.activityLocationLabel.text =  model.address + "\n" + cityName
            self.viewModel.activityLocation = model.address
            self.viewModel.activityLocationDesc.accept(model.name)
            self.viewModel.activityCityName = cityName
            if let coordinate = coordinate {
                self.viewModel.activityLocationLongitude = coordinate.longitude
                self.viewModel.activityLocationLatitude = coordinate.latitude
            }
        }
        self.present(vc, animated: true)
    }
    /// 保存草稿
    @IBAction func activitySaveDraftBtnClicked(_ sender: UIButton) {
        if self.viewModel.publishEditType == .detail {
            let checked = self.viewModel.isEditBaseInfoPage1Checked()
            guard checked else { return }
            
            // 详情编辑时为下一步
            let vc = GXPublishStep2VC.xibViewController().then {
                $0.viewModel = self.viewModel
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            // 保存草稿
            self.requestSaveActivityDraft()
        }
    }
    /// 下一步
    @IBAction func activityNextBtnClicked(_ sender: UIButton) {
        let checked = self.viewModel.isEditBaseInfoPage1Checked()
        guard checked else { return }

        if self.viewModel.publishEditType == .detail {
            // 详情编辑时为提交（修改基本资料）
            self.requestEditActivity()
        }
        else {
            // 下一步
            let vc = GXPublishStep2VC.xibViewController().then {
                $0.viewModel = self.viewModel
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
