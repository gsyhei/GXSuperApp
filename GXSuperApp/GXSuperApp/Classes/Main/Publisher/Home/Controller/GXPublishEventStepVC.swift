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
import HXPhotoPicker

class GXPublishEventStepVC: GXBaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    /// 事件名称
    @IBOutlet weak var eventNameTV: GXTextView!
    @IBOutlet weak var eventNameNumLabel: UILabel!
    /// 事件说明
    @IBOutlet weak var eventDescTV: GXTextView!
    @IBOutlet weak var eventDescNumLabel: UILabel!
    /// 事件时间
    @IBOutlet weak var beginDateBtn: UIButton!
    @IBOutlet weak var beginTimeBtn: UIButton!
    @IBOutlet weak var endDateBtn: UIButton!
    @IBOutlet weak var endTimeBtn: UIButton!
    /// 事件报名时间
    @IBOutlet weak var signBeginDateBtn: UIButton!
    @IBOutlet weak var signBeginTimeBtn: UIButton!
    @IBOutlet weak var signEndDateBtn: UIButton!
    @IBOutlet weak var signEndTimeBtn: UIButton!
    /// 事件地点
    @IBOutlet weak var eventAddressTV: GXTextView!
    @IBOutlet weak var eventAddressNumLabel: UILabel!
    /// 事件场地图-最大9张
    @IBOutlet weak var eventMapTopAddView: GXAddImagesView!
    @IBOutlet weak var eventMapTopAddViewHLC: NSLayoutConstraint!
    /// 事件地图描述
    @IBOutlet weak var eventPicsDescTV: GXTextView!
    @IBOutlet weak var eventMapDescNumLabel: UILabel!
    /// 事件描述图-最大9张
    @IBOutlet weak var eventDescTopAddView: GXAddImagesView!
    @IBOutlet weak var eventDescTopAddViewHLC: NSLayoutConstraint!
    /// 报名事件用户及奖励
    @IBOutlet weak var eventUserTitleLabel: UILabel!
    @IBOutlet weak var eventUserTableView: GXBaseTableView!
    @IBOutlet weak var eventUserTableViewHLC: NSLayoutConstraint!
    /// 保存并启用按钮
    @IBOutlet weak var saveEnableButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var enableButton: UIButton!

    private lazy var viewModel: GXPublishEventStepViewModel = {
        return GXPublishEventStepViewModel()
    }()

    class func createVC(activityData: GXActivityBaseInfoData, eventId: Int? = nil) -> GXPublishEventStepVC {
        return GXPublishEventStepVC.xibViewController().then {
            $0.viewModel.activityData = activityData
            $0.viewModel.eventId = eventId
            $0.hidesBottomBarWhenPushed = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetEventDetail()
    }

    override func setupViewController() {
        self.title = "事件"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.beginDateBtn.setBackgroundColor(.gx_background, for: .normal)
        self.beginTimeBtn.setBackgroundColor(.gx_background, for: .normal)
        self.endDateBtn.setBackgroundColor(.gx_background, for: .normal)
        self.endTimeBtn.setBackgroundColor(.gx_background, for: .normal)
        self.signBeginDateBtn.setBackgroundColor(.gx_background, for: .normal)
        self.signBeginTimeBtn.setBackgroundColor(.gx_background, for: .normal)
        self.signEndDateBtn.setBackgroundColor(.gx_background, for: .normal)
        self.signEndTimeBtn.setBackgroundColor(.gx_background, for: .normal)
        self.saveEnableButton.setBackgroundColor(.gx_green, for: .normal)
        self.saveButton.setBackgroundColor(.gx_green, for: .normal)
        self.enableButton.setBackgroundColor(.white, for: .normal)

        self.eventNameTV.placeholder = "事件名称"
        self.eventNameTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.eventNameTV.markedTextRange == nil else { return }
            guard var text = self.eventNameTV.text else { return }
            let maxCount: Int = 50
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.eventNameTV.text = text
            }
            self.eventNameNumLabel.text = "\(text.count)/\(maxCount)"
            self.eventNameNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)
        
        self.eventDescTV.placeholder = "事件说明"
        self.eventDescTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.eventDescTV.markedTextRange == nil else { return }
            guard var text = self.eventDescTV.text else { return }
            let maxCount: Int = 1000
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.eventDescTV.text = text
            }
            self.eventDescNumLabel.text = "\(text.count)/\(maxCount)"
            self.eventDescNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        self.eventAddressTV.placeholder = "填写地点"
        self.eventAddressTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.eventAddressTV.markedTextRange == nil else { return }
            guard var text = self.eventAddressTV.text else { return }
            let maxCount: Int = 50
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.eventAddressTV.text = text
            }
            self.eventAddressNumLabel.text = "\(text.count)/\(maxCount)"
            self.eventAddressNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        self.eventPicsDescTV.placeholder = "例如：奖励"
        self.eventPicsDescTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.eventPicsDescTV.markedTextRange == nil else { return }
            guard var text = self.eventPicsDescTV.text else { return }
            let maxCount: Int = 50
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.eventPicsDescTV.text = text
            }
            self.eventMapDescNumLabel.text = "\(text.count)/\(maxCount)"
            self.eventMapDescNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        // Bind input
        (self.eventNameTV.rx.textInput <-> self.viewModel.eventName).disposed(by: disposeBag)
        (self.eventDescTV.rx.textInput <-> self.viewModel.eventDesc).disposed(by: disposeBag)
        (self.eventAddressTV.rx.textInput <-> self.viewModel.eventAddress).disposed(by: disposeBag)
        (self.eventPicsDescTV.rx.textInput <-> self.viewModel.eventPicsDesc).disposed(by: disposeBag)

        self.eventMapTopAddView.backgroundColor = .clear
        self.eventMapTopAddView.maxAddCount = 9
        self.eventMapTopAddView.closeAction = {[weak self] height in
            self?.eventMapTopAddViewHLC.constant = height
        }
        self.eventMapTopAddView.addAction = {[weak self] in
            self?.showEventMapTopAddViewPhotoPicker()
        }
        self.eventMapTopAddView.previewAction = {[weak self] (index, cell) in
            self?.showEventMapTopAddViewBrowser(pageIndex: index, cell: cell)
        }

        self.eventDescTopAddView.backgroundColor = .clear
        self.eventDescTopAddView.maxAddCount = 9
        self.eventDescTopAddView.closeAction = {[weak self] height in
            self?.eventDescTopAddViewHLC.constant = height
        }
        self.eventDescTopAddView.addAction = {[weak self] in
            self?.showEventDescTopAddViewPhotoPicker()
        }
        self.eventDescTopAddView.previewAction = {[weak self] (index, cell) in
            self?.showEventDescTopAddViewBrowser(pageIndex: index, cell: cell)
        }

        self.eventUserTableView.register(cellType: GXPublishEventSignUserCell.self)
        self.eventUserTableView.separatorColor = .gx_lightGray
        self.eventUserTableView.rowHeight = 60.0
        self.eventUserTableView.dataSource = self
        self.eventUserTableView.delegate = self
        self.eventUserTableView.isScrollEnabled = false
        if self.viewModel.eventId == nil {
            self.eventUserTitleLabel.isHidden = true
            self.eventUserTableView.isHidden = true
            self.eventUserTableViewHLC.constant = 0
            self.saveButton.isHidden = true
            self.enableButton.isHidden = true
            self.saveEnableButton.isHidden = false
        }
        else {
            self.eventUserTitleLabel.isHidden = false
            self.eventUserTableView.isHidden = false
            self.eventUserTableViewHLC.constant = 0
            self.saveButton.isHidden = true
            self.enableButton.isHidden = true
            self.saveEnableButton.isHidden = true
        }
    }

    /// 设置编辑内容
    func updateInfoInput() {
        if self.viewModel.eventId != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "m_qrcode_icon"), style: .plain, target: self, action: #selector(self.rightButtonItemTapped))
        }

        self.beginDateBtn.setTitle(self.viewModel.beginDate?.string(format: "yyyy年MM月dd日") ?? "--", for: .normal)
        self.beginTimeBtn.setTitle(self.viewModel.beginTime, for: .normal)
        self.endDateBtn.setTitle(self.viewModel.endDate?.string(format: "yyyy年MM月dd日") ?? "--", for: .normal)
        self.endTimeBtn.setTitle(self.viewModel.endTime, for: .normal)

        self.signBeginDateBtn.setTitle(self.viewModel.signBeginDate?.string(format: "yyyy年MM月dd日") ?? "--", for: .normal)
        self.signBeginTimeBtn.setTitle(self.viewModel.signBeginTime, for: .normal)
        self.signEndDateBtn.setTitle(self.viewModel.signEndDate?.string(format: "yyyy年MM月dd日") ?? "--", for: .normal)
        self.signEndTimeBtn.setTitle(self.viewModel.signEndTime, for: .normal)

        self.eventMapTopAddView.images = self.viewModel.eventMapImages
        self.eventMapTopAddViewHLC.constant = self.eventMapTopAddView.getShowHeight()

        self.eventDescTopAddView.images = self.viewModel.eventDescImages
        self.eventDescTopAddViewHLC.constant = self.eventDescTopAddView.getShowHeight()

        guard let data = self.viewModel.detailData else { return }

        let signsCount: Int = data.eventSigns?.count ?? 0
        self.eventUserTableViewHLC.constant = 60.0 * CGFloat(signsCount)
        self.eventUserTableView.reloadData()

        guard let eventStatus = data.eventStatus else { return }

        //事件状态 0-禁用 1-启用-进行中 2-启用-已结束 3-平台禁用
        switch eventStatus {
        case 0:
            self.saveButton.isHidden = false
            self.enableButton.isHidden = false
            self.saveEnableButton.isHidden = true
            self.enableButton.setTitle("启用", for: .normal)
            self.enableButton.gx_setGreenBorderButton()

        case 1:
            self.saveButton.isHidden = false
            self.enableButton.isHidden = false
            self.saveEnableButton.isHidden = true
            self.enableButton.setTitle("禁用", for: .normal)
            self.enableButton.gx_setRedBorderButton()
        case 2:
            self.saveButton.isHidden = true
            self.enableButton.isHidden = true
            self.saveEnableButton.isHidden = false
            self.saveEnableButton.setTitle("事件已结束", for: .disabled)
            self.saveEnableButton.gx_setDisabledButton()
        case 3:
            self.saveButton.isHidden = false
            self.enableButton.isHidden = false
            self.saveEnableButton.isHidden = true
            self.enableButton.setTitle("平台禁用", for: .disabled)
            self.enableButton.setTitleColor(.gx_red, for: .disabled)
            self.enableButton.gx_setDisabledButton()
        default: break
        }
    }

}

extension GXPublishEventStepVC {
    func showEventMapTopAddViewPhotoPicker() {
        var config: PickerConfiguration = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.selectMode = .multiple
        config.selectOptions = .photo
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoSelectionTapAction = .openEditor
        config.photoList.rowNumber = 3
        config.maximumSelectedCount = (9 - self.eventMapTopAddView.images.count)
        let vc = PhotoPickerController.init(config: config)
        vc.finishHandler = {[weak self] (result, picker) in
            self?.eventMapTopAddView.images.append(contentsOf: result.photoAssets)
            self?.eventMapTopAddViewHLC.constant = self?.eventMapTopAddView.getShowHeight() ?? 0
            self?.viewModel.eventMapImages = self?.eventMapTopAddView.images ?? []
        }
        self.present(vc, animated: true, completion: nil)
    }
    func showEventMapTopAddViewBrowser(pageIndex: Int, cell: GXAddImageCell) {
        HXPhotoPicker.PhotoBrowser.show(pageIndex: pageIndex, transitionalImage: cell.imageView.image) {
            self.eventMapTopAddView.images.count
        } assetForIndex: {
            self.eventMapTopAddView.images[$0]
        } transitionAnimator: { index in
            self.eventMapTopAddView.cellForItem(at: IndexPath(item: index,section: 0)) as? GXAddImageCell
        }
    }

    func showEventDescTopAddViewPhotoPicker() {
        var config: PickerConfiguration = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.selectMode = .multiple
        config.selectOptions = .photo
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoSelectionTapAction = .openEditor
        config.photoList.rowNumber = 3
        config.maximumSelectedCount = (9 - self.eventDescTopAddView.images.count)
        let vc = PhotoPickerController.init(config: config)
        vc.finishHandler = {[weak self] (result, picker) in
            self?.eventDescTopAddView.images.append(contentsOf: result.photoAssets)
            self?.eventDescTopAddViewHLC.constant = self?.eventDescTopAddView.getShowHeight() ?? 0
            self?.viewModel.eventDescImages = self?.eventDescTopAddView.images ?? []
        }
        self.present(vc, animated: true, completion: nil)
    }
    func showEventDescTopAddViewBrowser(pageIndex: Int, cell: GXAddImageCell) {
        HXPhotoPicker.PhotoBrowser.show(pageIndex: pageIndex, transitionalImage: cell.imageView.image) {
            self.eventDescTopAddView.images.count
        } assetForIndex: {
            self.eventDescTopAddView.images[$0]
        } transitionAnimator: { index in
            self.eventDescTopAddView.cellForItem(at: IndexPath(item: index,section: 0)) as? GXAddImageCell
        }
    }

    func requestAllLoadAddEvent() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestAllLoadAddEvent(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showSuccess(text: "保存成功")
            self?.navigationController?.popViewController(animated: true)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestAllLoadUpdateEvent() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestAllLoadUpdateEvent(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showSuccess(text: "保存成功")
            self?.navigationController?.popViewController(animated: true)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
    
    func requestModifyEventStatus() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestModifyEventStatus(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showSuccess(text: "操作成功", to: self?.view)
            self?.updateInfoInput()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestGetEventDetail() {
        guard (self.viewModel.eventId != nil) else { return }
        
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetEventDetail(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.updateInfoInput()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestSendAwardMessage(data: GXPublishEventsignsData) {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestSendAwardMessage(data: data, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.eventUserTableView.reloadData()
            GXToast.showSuccess(text: "消息已发送", to: self?.view)
        }, failure: {[weak self] error in
            data.eventReward = nil
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXPublishEventStepVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.detailData?.eventSigns?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPublishEventSignUserCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.detailData?.eventSigns?[indexPath.row]
        cell.bindCell(model: model)
        cell.avatarAction = {[weak self] curCell in
            guard let `self` = self else { return }
            guard let curIndexPath = self.eventUserTableView.indexPath(for: curCell) else { return }
            guard let userId = self.viewModel.detailData?.eventSigns?[curIndexPath.row].userId else { return }
            GXMinePtOtherVC.push(fromVC: self, userId: String(userId))
        }
        cell.senderAction = {[weak self] curCell in
            guard let `self` = self else { return }
            guard let curIndexPath = self.eventUserTableView.indexPath(for: curCell) else { return }
            guard let eventsignsData = self.viewModel.detailData?.eventSigns?[curIndexPath.row] else { return }
            eventsignsData.eventReward = curCell.textField.text
            self.requestSendAwardMessage(data: eventsignsData)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension GXPublishEventStepVC {

    @IBAction func beginDateBtnClicked(_ sender: UIButton) {
        let pickerDateView: GXDatePickerView = {
            return GXDatePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 560)
                $0.setSelectedDate(self.viewModel.beginDate)
                $0.completion = {[weak self] date in
                    self?.viewModel.beginDate = date
                    self?.beginDateBtn.setTitle(date.string(format: "yyyy年MM月dd日"), for: .normal)
                }
            }
        }()
        pickerDateView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }

    @IBAction func beginTimeBtnClicked(_ sender: UIButton) {
        let pickerTimeView: GXTimePickerView = {
            return GXTimePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 360)
                $0.completion = {[weak self] time in
                    self?.viewModel.beginTime = time
                    self?.beginTimeBtn.setTitle(time, for: .normal)
                }
            }
        }()
        pickerTimeView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }

    @IBAction func endDateBtnClicked(_ sender: UIButton) {
        let pickerDateView: GXDatePickerView = {
            return GXDatePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 560)
                $0.setSelectedDate(self.viewModel.endDate)
                $0.completion = {[weak self] date in
                    self?.viewModel.endDate = date
                    self?.endDateBtn.setTitle(date.string(format: "yyyy年MM月dd日"), for: .normal)
                }
            }
        }()
        pickerDateView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }

    @IBAction func endTimeBtnClicked(_ sender: UIButton) {
        let pickerTimeView: GXTimePickerView = {
            return GXTimePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 360)
                $0.completion = {[weak self] time in
                    self?.viewModel.endTime = time
                    self?.endTimeBtn.setTitle(time, for: .normal)
                }
            }
        }()
        pickerTimeView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }

    @IBAction func signBeginDateBtnClicked(_ sender: UIButton) {
        let pickerDateView: GXDatePickerView = {
            return GXDatePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 560)
                $0.setSelectedDate(self.viewModel.signBeginDate)
                $0.completion = {[weak self] date in
                    self?.viewModel.signBeginDate = date
                    self?.signBeginDateBtn.setTitle(date.string(format: "yyyy年MM月dd日"), for: .normal)
                }
            }
        }()
        pickerDateView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }

    @IBAction func signBeginTimeBtnClicked(_ sender: UIButton) {
        let pickerTimeView: GXTimePickerView = {
            return GXTimePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 360)
                $0.completion = {[weak self] time in
                    self?.viewModel.signBeginTime = time
                    self?.signBeginTimeBtn.setTitle(time, for: .normal)
                }
            }
        }()
        pickerTimeView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }

    @IBAction func signEndDateBtnClicked(_ sender: UIButton) {
        let pickerDateView: GXDatePickerView = {
            return GXDatePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 560)
                $0.setSelectedDate(self.viewModel.signEndDate)
                $0.completion = {[weak self] date in
                    self?.viewModel.signEndDate = date
                    self?.signEndDateBtn.setTitle(date.string(format: "yyyy年MM月dd日"), for: .normal)
                }
            }
        }()
        pickerDateView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }

    @IBAction func signEndTimeBtnClicked(_ sender: UIButton) {
        let pickerTimeView: GXTimePickerView = {
            return GXTimePickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 360)
                $0.completion = {[weak self] time in
                    self?.viewModel.signEndTime = time
                    self?.signEndTimeBtn.setTitle(time, for: .normal)
                }
            }
        }()
        pickerTimeView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }

    @IBAction func saveEnableButtonClicked(_ sender: UIButton) {
        if self.eventNameTV.text?.count == 0 {
            GXToast.showError(text: "请输入事件名称！")
            return
        }
        if (self.viewModel.beginDate == nil ||
            self.viewModel.beginTime == nil ||
            self.viewModel.endDate == nil ||
            self.viewModel.endTime == nil) {
            GXToast.showError(text: "请完善事件时间！")
            return
        }
        self.requestAllLoadAddEvent()
    }

    @IBAction func saveButtonClicked(_ sender: UIButton) {
        if self.eventNameTV.text?.count == 0 {
            GXToast.showError(text: "请输入事件名称！")
            return
        }
        if (self.viewModel.beginDate == nil ||
            self.viewModel.beginTime == nil ||
            self.viewModel.endDate == nil ||
            self.viewModel.endTime == nil) {
            GXToast.showError(text: "请完善事件时间！")
            return
        }
        self.requestAllLoadUpdateEvent()
    }

    @IBAction func enableButtonClicked(_ sender: UIButton) {
        self.requestModifyEventStatus()
    }

    @objc func rightButtonItemTapped() {
        if let eventId = self.viewModel.eventId {
            GXMinePtQrCodeView.showAlertView(type: .event, text: String(eventId))
        }
        else if let eventId = self.viewModel.detailData?.id {
            GXMinePtQrCodeView.showAlertView(type: .event, text: String(eventId))
        }
    }
}
