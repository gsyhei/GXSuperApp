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

class GXMineFeedbackVC: GXBaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    /// 反馈说明
    @IBOutlet weak var descTV: GXTextView!
    @IBOutlet weak var descNumLabel: UILabel!
    /// 反馈主图-最大9张
    @IBOutlet weak var feedbackAddView: GXAddImages9View!
    @IBOutlet weak var feedbackAddViewHLC: NSLayoutConstraint!
    /// 提交按钮
    @IBOutlet weak var submitButton: UIButton!

    private lazy var viewModel: GXMineFeedbackViewModel = {
        return GXMineFeedbackViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "用户反馈"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.submitButton.setBackgroundColor(.gx_green, for: .normal)
        self.descTV.placeholder = "请输入关于APP使用方面的意见，非订单问题"
        self.descTV.gx_setMarginZero()
        self.descTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.descTV.markedTextRange == nil else { return }
            guard var text = self.descTV.text else { return }
            let maxCount: Int = 2000
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.descTV.text = text
            }
            self.descNumLabel.text = "\(text.count)/\(maxCount)"
            self.descNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        // Bind input
        (self.descTV.rx.textInput <-> self.viewModel.descInput).disposed(by: disposeBag)

        self.feedbackAddView.backgroundColor = .clear
        self.feedbackAddView.maxAddCount = 9
        self.feedbackAddView.closeAction = {[weak self] height in
            self?.feedbackAddViewHLC.constant = height
        }
        self.feedbackAddView.addAction = {[weak self] in
            self?.showAddViewPhotoPicker()
        }
        self.feedbackAddView.previewAction = {[weak self] (index, cell) in
            self?.showAddViewBrowser(pageIndex: index, cell: cell)
        }
        self.feedbackAddView.images = self.viewModel.images
        self.feedbackAddViewHLC.constant = self.feedbackAddView.getShowHeight()
    }
}

extension GXMineFeedbackVC {
    func requestAllFeedbackCreate() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestAllFeedbackCreate(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showSuccess(text: "提交成功，感谢您的反馈")
            self.navigationController?.popViewController(animated: true)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXMineFeedbackVC {

    func showAddViewPhotoPicker() {
        var config: PickerConfiguration = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.selectMode = .multiple
        config.selectOptions = .photo
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoSelectionTapAction = .openEditor
        config.photoList.rowNumber = 3
        config.maximumSelectedCount = (9 - self.feedbackAddView.images.count)
        let vc = PhotoPickerController.init(config: config)
        vc.finishHandler = {[weak self] (result, picker) in
            self?.feedbackAddView.images.append(contentsOf: result.photoAssets)
            self?.viewModel.images = self?.feedbackAddView.images ?? []
            self?.feedbackAddViewHLC.constant = self?.feedbackAddView.getShowHeight() ?? 0
        }
        self.present(vc, animated: true, completion: nil)
    }

    func showAddViewBrowser(pageIndex: Int, cell: GXAddImage9Cell) {
        HXPhotoPicker.PhotoBrowser.show(pageIndex: pageIndex, transitionalImage: cell.imageView.image) {
            self.feedbackAddView.images.count
        } assetForIndex: {
            self.feedbackAddView.images[$0]
        } transitionAnimator: { index in
            self.feedbackAddView.cellForItem(at: IndexPath(item: index,section: 0)) as? GXAddImage9Cell
        }
    }

    @IBAction func submitButtonClicked(_ sender: UIButton) {
        if (self.viewModel.descInput.value ?? "").isEmpty {
            GXToast.showError(text: "请输入反馈内容", to: self.view)
            return
        }
        if (self.viewModel.descInput.value?.count ?? 0) < 10 {
            GXToast.showError(text: "至少输入10个字", to: self.view)
            return
        }
        self.requestAllFeedbackCreate()
    }

}
