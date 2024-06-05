//
//  GXPublishReviewEidtVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/21.
//

import UIKit
import HXPhotoPicker
import RxCocoaPlus
import MBProgressHUD

class GXPublishReviewEidtVC: GXBaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    /// 回顾说明
    @IBOutlet weak var reviewDescTV: GXTextView!
    @IBOutlet weak var reviewDescNumLabel: UILabel!
    /// 回顾主图-最大9张
    @IBOutlet weak var reviewAddView: GXAddImages9View!
    @IBOutlet weak var reviewAddViewHLC: NSLayoutConstraint!
    /// 提交按钮
    @IBOutlet weak var submitButton: UIButton!

    private lazy var viewModel: GXPublishReviewEidtViewModel = {
        return GXPublishReviewEidtViewModel()
    }()

    class func createVC(activityId: Int, roleType: String? = nil, data: GXActivityreviewsListItem? = nil) -> GXPublishReviewEidtVC {
        return GXPublishReviewEidtVC.xibViewController().then {
            $0.viewModel.activityId = activityId
            $0.viewModel.roleType = roleType
            $0.viewModel.data = data
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "编辑回顾"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.submitButton.setBackgroundColor(.gx_green, for: .normal)
        self.reviewDescTV.placeholder = "输入回顾内容"
        self.reviewDescTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.reviewDescTV.markedTextRange == nil else { return }
            guard var text = self.reviewDescTV.text else { return }
            let maxCount: Int = 500
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.reviewDescTV.text = text
            }
            self.reviewDescNumLabel.text = "\(text.count)/\(maxCount)"
            self.reviewDescNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        // Bind input
        (self.reviewDescTV.rx.textInput <-> self.viewModel.reviewDescInput).disposed(by: disposeBag)

        self.reviewAddView.backgroundColor = .clear
        self.reviewAddView.maxAddCount = 9
        self.reviewAddView.closeAction = {[weak self] height in
            self?.reviewAddViewHLC.constant = height
        }
        self.reviewAddView.addAction = {[weak self] in
            self?.showReviewAddViewPhotoPicker()
        }
        self.reviewAddView.previewAction = {[weak self] (index, cell) in
            self?.showReviewAddViewBrowser(pageIndex: index, cell: cell)
        }
        self.reviewAddView.images = self.viewModel.reviewImages
        self.reviewAddViewHLC.constant = self.reviewAddView.getShowHeight()
    }
}

extension GXPublishReviewEidtVC {
    func requestSubmitReview() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestSubmitReview(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.reviewAddView.images = self.viewModel.reviewImages
            self.reviewAddViewHLC.constant = self.reviewAddView.getShowHeight()
            self.showSubmitReviewAlert()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func showSubmitReviewAlert() {
        if GXRoleUtil.isAdmin(roleType: self.viewModel.roleType) {
            GXToast.showSuccess(text: "提交成功")
            self.navigationController?.popViewController(animated: true)
        }
        else {
            let title = "提交成功\n待审核通过后所有用户可见！"
            GXUtil.showAlert(title: title, cancelTitle: "我知道了") { alert, index in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension GXPublishReviewEidtVC {

    func showReviewAddViewPhotoPicker() {
        var config: PickerConfiguration = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.selectMode = .multiple
        config.selectOptions = .photo
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoSelectionTapAction = .openEditor
        config.photoList.rowNumber = 3
        config.maximumSelectedCount = (9 - self.reviewAddView.images.count)
        let vc = PhotoPickerController.init(config: config)
        vc.finishHandler = {[weak self] (result, picker) in
            self?.reviewAddView.images.append(contentsOf: result.photoAssets)
            self?.viewModel.reviewImages = self?.reviewAddView.images ?? []
            self?.reviewAddViewHLC.constant = self?.reviewAddView.getShowHeight() ?? 0
        }
        self.present(vc, animated: true, completion: nil)
    }

    func showReviewAddViewBrowser(pageIndex: Int, cell: GXAddImage9Cell) {
        HXPhotoPicker.PhotoBrowser.show(pageIndex: pageIndex, transitionalImage: cell.imageView.image) {
            self.reviewAddView.images.count
        } assetForIndex: {
            self.reviewAddView.images[$0]
        } transitionAnimator: { index in
            self.reviewAddView.cellForItem(at: IndexPath(item: index,section: 0)) as? GXAddImage9Cell
        }
    }

    @IBAction func submitButtonClicked(_ sender: UIButton) {
        if (self.viewModel.reviewDescInput.value ?? "").isEmpty {
            GXToast.showError(text: "请输入回顾内容", to: self.view)
            return
        }
        if (self.viewModel.reviewDescInput.value?.count ?? 0) < 5 {
            GXToast.showError(text: "至少填写5个字", to: self.view)
            return
        }
        self.requestSubmitReview()
    }

}
