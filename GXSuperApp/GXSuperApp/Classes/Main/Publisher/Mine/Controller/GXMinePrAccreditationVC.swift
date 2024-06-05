//
//  GXMinePrAccreditationVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/21.
//

import UIKit
import HXPhotoPicker
import RxCocoaPlus
import MBProgressHUD

class GXMinePrAccreditationVC: GXBaseWarnViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    /// 机构名称
    @IBOutlet weak var descTV: GXTextView!
    @IBOutlet weak var descNumLabel: UILabel!
    /// 机构证书图-最大9张
    @IBOutlet weak var addView: GXAddImages9View!
    @IBOutlet weak var addViewHLC: NSLayoutConstraint!
    /// 提交按钮
    @IBOutlet weak var submitButton: UIButton!

    private lazy var viewModel: GXMinePrAccreditationViewModel = {
        return GXMinePrAccreditationViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetOrgAccreditation()
    }

    override func setupViewController() {
        self.title = "机构认证"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.submitButton.setBackgroundColor(.gx_green, for: .normal)
        self.descTV.placeholder = "请填写机构名称"
        self.descTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.descTV.markedTextRange == nil else { return }
            guard var text = self.descTV.text else { return }
            let maxCount: Int = 50
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.descTV.text = text
            }
            self.descNumLabel.text = "\(text.count)/\(maxCount)"
            self.descNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        // Bind input
        (self.descTV.rx.textInput <-> self.viewModel.descInput).disposed(by: disposeBag)

        self.addView.backgroundColor = .clear
        self.addView.addBackgroudColor = .white
        self.addView.maxAddCount = 1
        self.addView.closeAction = {[weak self] height in
            self?.addViewHLC.constant = height
        }
        self.addView.addAction = {[weak self] in
            self?.showAddViewPhotoPicker()
        }
        self.addView.previewAction = {[weak self] (index, cell) in
            self?.showAddViewBrowser(pageIndex: index, cell: cell)
        }
        self.addView.images = self.viewModel.images
        self.addViewHLC.constant = self.addView.getShowHeight()
    }
}

extension GXMinePrAccreditationVC {
    func requestGetOrgAccreditation() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetOrgAccreditation(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.updateInfoInput()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
    func requestAllSubmitOrgAccreditation() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestAllSubmitOrgAccreditation(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.showEditSuccessAlert()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
    func showEditSuccessAlert() {
        let title = "提交成功\n平台会在1-2个工作日内审核\n请耐心等待！"
        GXUtil.showAlert(title: title, cancelTitle: "我知道了") { alert, index in
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    func updateInfoInput() {
        self.addView.images = self.viewModel.images
        self.addViewHLC.constant = self.addView.getShowHeight()

        guard let data = self.viewModel.data else { return }
        // 审核状态 0-待审核 1-已审核 2-未通过
        
        switch data.approveStatus {
        case 0:
            self.scrollView.isUserInteractionEnabled = false
            self.submitButton.setTitle("待审核", for: .disabled)
            self.submitButton.gx_setDisabledButton()
        case 1:
            self.scrollView.isUserInteractionEnabled = false
            self.submitButton.setTitle("已认证", for: .disabled)
            self.submitButton.gx_setDisabledButton()
        case 2:
            let text = "审核未通过\n原因：\(data.rejectReason)"
            self.gx_showWarning(text: text)
            self.scrollView.isUserInteractionEnabled = true
            self.submitButton.setTitle("重新提交", for: .normal)
            self.submitButton.gx_setGreenButton()
        default: break
        }
    }
}

extension GXMinePrAccreditationVC {

    func showAddViewPhotoPicker() {
        var config: PickerConfiguration = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.selectMode = .multiple
        config.selectOptions = .photo
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoSelectionTapAction = .openEditor
        config.photoList.rowNumber = 3
        config.maximumSelectedCount = 1
        let vc = PhotoPickerController.init(config: config)
        vc.finishHandler = {[weak self] (result, picker) in
            self?.addView.images.append(contentsOf: result.photoAssets)
            self?.viewModel.images = self?.addView.images ?? []
            self?.addViewHLC.constant = self?.addView.getShowHeight() ?? 0
        }
        self.present(vc, animated: true, completion: nil)
    }

    func showAddViewBrowser(pageIndex: Int, cell: GXAddImage9Cell) {
        HXPhotoPicker.PhotoBrowser.show(pageIndex: pageIndex, transitionalImage: cell.imageView.image) {
            self.addView.images.count
        } assetForIndex: {
            self.addView.images[$0]
        } transitionAnimator: { index in
            self.addView.cellForItem(at: IndexPath(item: index,section: 0)) as? GXAddImage9Cell
        }
    }

    @IBAction func submitButtonClicked(_ sender: UIButton) {
        if (self.viewModel.descInput.value ?? "").isEmpty {
            GXToast.showError(text: "请填写机构名称", to: self.view)
            return
        }
        if self.viewModel.images.count == 0 {
            GXToast.showError(text: "请上传机构证书", to: self.view)
            return
        }
        self.requestAllSubmitOrgAccreditation()
    }

}
