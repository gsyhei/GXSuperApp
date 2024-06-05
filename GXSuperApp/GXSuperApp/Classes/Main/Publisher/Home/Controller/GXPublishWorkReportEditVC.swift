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

class GXPublishWorkReportEditVC: GXBaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    /// 工作汇报说明
    @IBOutlet weak var workProgressTV: GXTextView!
    @IBOutlet weak var workProgressNumLabel: UILabel!
    /// 工作汇报主图-最大9张
    @IBOutlet weak var reportAddView: GXAddImages9View!
    @IBOutlet weak var reportAddViewHLC: NSLayoutConstraint!
    /// 提交按钮
    @IBOutlet weak var submitButton: UIButton!

    private lazy var viewModel: GXPublishWorkReportEditViewModel = {
        return GXPublishWorkReportEditViewModel()
    }()

    class func createVC(activityId: Int, data: GXActivityreportsItem? = nil) -> GXPublishWorkReportEditVC {
        return GXPublishWorkReportEditVC.xibViewController().then {
            $0.viewModel.activityId = activityId
            $0.viewModel.data = data
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "编辑工作汇报"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.submitButton.setBackgroundColor(.gx_green, for: .normal)
        self.workProgressTV.placeholder = "输入工作汇报内容"
        self.workProgressTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.workProgressTV.markedTextRange == nil else { return }
            guard var text = self.workProgressTV.text else { return }
            let maxCount: Int = 1000
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.workProgressTV.text = text
            }
            self.workProgressNumLabel.text = "\(text.count)/\(maxCount)"
            self.workProgressNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        // Bind input
        (self.workProgressTV.rx.textInput <-> self.viewModel.workProgressInput).disposed(by: disposeBag)

        self.reportAddView.backgroundColor = .clear
        self.reportAddView.maxAddCount = 9
        self.reportAddView.closeAction = {[weak self] height in
            self?.reportAddViewHLC.constant = height
        }
        self.reportAddView.addAction = {[weak self] in
            self?.showReviewAddViewPhotoPicker()
        }
        self.reportAddView.previewAction = {[weak self] (index, cell) in
            self?.showReviewAddViewBrowser(pageIndex: index, cell: cell)
        }
        self.reportAddView.images = self.viewModel.reportImages
        self.reportAddViewHLC.constant = self.reportAddView.getShowHeight()
    }
}

extension GXPublishWorkReportEditVC {
    func requestSubmitReview() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestSubmitReport(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.reportAddView.images = self.viewModel.reportImages
            self.reportAddViewHLC.constant = self.reportAddView.getShowHeight()
            GXToast.showSuccess(text: "提交成功")
            self.navigationController?.popViewController(animated: true)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXPublishWorkReportEditVC {

    func showReviewAddViewPhotoPicker() {
        var config: PickerConfiguration = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.selectMode = .multiple
        config.selectOptions = .photo
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoSelectionTapAction = .openEditor
        config.photoList.rowNumber = 3
        config.maximumSelectedCount = (9 - self.reportAddView.images.count)
        let vc = PhotoPickerController.init(config: config)
        vc.finishHandler = {[weak self] (result, picker) in
            self?.reportAddView.images.append(contentsOf: result.photoAssets)
            self?.viewModel.reportImages = self?.reportAddView.images ?? []
            self?.reportAddViewHLC.constant = self?.reportAddView.getShowHeight() ?? 0
        }
        self.present(vc, animated: true, completion: nil)
    }

    func showReviewAddViewBrowser(pageIndex: Int, cell: GXAddImage9Cell) {
        HXPhotoPicker.PhotoBrowser.show(pageIndex: pageIndex, transitionalImage: cell.imageView.image) {
            self.reportAddView.images.count
        } assetForIndex: {
            self.reportAddView.images[$0]
        } transitionAnimator: { index in
            self.reportAddView.cellForItem(at: IndexPath(item: index,section: 0)) as? GXAddImage9Cell
        }
    }

    @IBAction func submitButtonClicked(_ sender: UIButton) {
        if (self.viewModel.workProgressInput.value ?? "").isEmpty {
            GXToast.showError(text: "请输入工作汇报内容", to: self.view)
            return
        }
        self.requestSubmitReview()
    }

}
