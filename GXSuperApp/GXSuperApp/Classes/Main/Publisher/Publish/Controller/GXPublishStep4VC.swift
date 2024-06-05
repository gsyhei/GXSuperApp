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
import HXPhotoPicker

class GXPublishStep4VC: GXBaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    /// 活动图片-单张
    @IBOutlet weak var activityAddView: GXAddImagesView!
    @IBOutlet weak var activityAddViewHLC: NSLayoutConstraint!
    /// 活动详情顶部图片-最大9张
    @IBOutlet weak var activityDetailTopAddView: GXAddImagesView!
    @IBOutlet weak var activityDetailTopAddViewHLC: NSLayoutConstraint!
    /// 活动详情介绍
    @IBOutlet weak var activityDetailDescAddView: GXAddImagesView!
    @IBOutlet weak var activityDetailDescAddViewHLC: NSLayoutConstraint!
    /// 我同意《产品服务协议》
    @IBOutlet weak var activityCheckButton: UIButton!
    @IBOutlet weak var activityInfoTextView: GXLinkTextView!
    /// 底部栏
    @IBOutlet weak var activitySaveDraftBtn: UIButton!
    @IBOutlet weak var activityLastBtn: UIButton!
    @IBOutlet weak var activitySubmitBtn: UIButton!

    weak var viewModel: GXPublishStepViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "发布活动"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.activityCheckButton.isSelected = self.viewModel.activityAgreementCheck
        self.activityInfoTextView.gx_setMarginZero()
        self.activityInfoTextView.gx_appendLink(string: "《产品服务协议》", color: UIColor.gx_blue, urlString: "cpfwxy")
        self.activityInfoTextView.delegate = self

        self.activitySaveDraftBtn.setBackgroundColor(.white, for: .normal)
        self.activityLastBtn.setBackgroundColor(.gx_lightPublicGreen, for: .normal)
        self.activitySubmitBtn.setBackgroundColor(.gx_green, for: .normal)

        self.activityAddView.backgroundColor = .clear
        self.activityAddView.maxAddCount = 1
        self.activityAddView.closeAction = {[weak self] height in
            self?.activityAddViewHLC.constant = height
        }
        self.activityAddView.addAction = {[weak self] in
            self?.showActivityAddViewPhotoPicker()
        }
        self.activityAddView.previewAction = {[weak self] (index, cell) in
            self?.showActivityAddViewBrowser(pageIndex: index, cell: cell)
        }

        self.activityDetailTopAddView.backgroundColor = .clear
        self.activityDetailTopAddView.maxAddCount = 9
        self.activityDetailTopAddView.closeAction = {[weak self] height in
            self?.activityDetailTopAddViewHLC.constant = height
        }
        self.activityDetailTopAddView.addAction = {[weak self] in
            self?.showActivityDetailTopAddViewPhotoPicker()
        }
        self.activityDetailTopAddView.previewAction = {[weak self] (index, cell) in
            self?.showActivityDetailAddViewBrowser(pageIndex: index, cell: cell)
        }

        self.activityDetailDescAddView.backgroundColor = .clear
        self.activityDetailDescAddView.maxAddCount = 9
        self.activityDetailDescAddView.closeAction = {[weak self] height in
            self?.activityDetailDescAddViewHLC.constant = height
        }
        self.activityDetailDescAddView.addAction = {[weak self] in
            self?.activityDetailDescAddViewPhotoPicker()
        }
        self.activityDetailDescAddView.previewAction = {[weak self] (index, cell) in
            self?.showActivityDetailDescAddViewBrowser(pageIndex: index, cell: cell)
        }

        // 改变底栏按钮
        if self.viewModel.publishEditType == .detail {
            self.activitySaveDraftBtn.isHidden = true
            self.activitySubmitBtn.setTitle("提交", for: .normal)
        }

        self.updateInfoInput()
    }

    /// 设置编辑内容
    func updateInfoInput() {
        self.activityAddView.images = self.viewModel.activityImages
        self.activityAddViewHLC.constant = self.activityAddView.getShowHeight()

        self.activityDetailTopAddView.images = self.viewModel.activityDetailImages
        self.activityDetailTopAddViewHLC.constant = self.activityDetailTopAddView.getShowHeight()

        self.activityDetailDescAddView.images = self.viewModel.activityDetailDescImages
        self.activityDetailDescAddViewHLC.constant = self.activityDetailDescAddView.getShowHeight()
    }

}

private extension GXPublishStep4VC {
    func showActivityAddViewPhotoPicker() {
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
            self?.activityAddView.images = result.photoAssets
            self?.viewModel.activityImages = self?.activityAddView.images ?? []
            self?.activityAddViewHLC.constant = self?.activityAddView.getShowHeight() ?? 0
        }
        self.present(vc, animated: true, completion: nil)
    }

    func showActivityDetailTopAddViewPhotoPicker() {
        var config: PickerConfiguration = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.selectMode = .multiple
        config.selectOptions = .photo
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoSelectionTapAction = .openEditor
        config.photoList.rowNumber = 3
        config.maximumSelectedCount = (9 - self.activityDetailTopAddView.images.count)
        let vc = PhotoPickerController.init(config: config)
        vc.finishHandler = {[weak self] (result, picker) in
            self?.activityDetailTopAddView.images.append(contentsOf: result.photoAssets)
            self?.viewModel.activityDetailImages = self?.activityDetailTopAddView.images ?? []
            self?.activityDetailTopAddViewHLC.constant = self?.activityDetailTopAddView.getShowHeight() ?? 0
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func activityDetailDescAddViewPhotoPicker() {
        var config: PickerConfiguration = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.selectMode = .multiple
        config.selectOptions = .photo
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoSelectionTapAction = .openEditor
        config.photoList.rowNumber = 3
        config.maximumSelectedCount = (9 - self.activityDetailDescAddView.images.count)
        let vc = PhotoPickerController.init(config: config)
        vc.finishHandler = {[weak self] (result, picker) in
            self?.activityDetailDescAddView.images.append(contentsOf: result.photoAssets)
            self?.viewModel.activityDetailDescImages = self?.activityDetailDescAddView.images ?? []
            self?.activityDetailDescAddViewHLC.constant = self?.activityDetailDescAddView.getShowHeight() ?? 0
        }
        self.present(vc, animated: true, completion: nil)
    }

    func showActivityAddViewBrowser(pageIndex: Int, cell: GXAddImageCell) {
        HXPhotoPicker.PhotoBrowser.show(pageIndex: pageIndex, transitionalImage: cell.imageView.image) {
            self.activityAddView.images.count
        } assetForIndex: {
            self.activityAddView.images[$0]
        } transitionAnimator: { index in
            self.activityAddView.cellForItem(at: IndexPath(item: index,section: 0)) as? GXAddImageCell
        }
    }

    func showActivityDetailAddViewBrowser(pageIndex: Int, cell: GXAddImageCell) {
        HXPhotoPicker.PhotoBrowser.show(pageIndex: pageIndex, transitionalImage: cell.imageView.image) {
            self.activityDetailTopAddView.images.count
        } assetForIndex: {
            self.activityDetailTopAddView.images[$0]
        } transitionAnimator: { index in
            self.activityDetailTopAddView.cellForItem(at: IndexPath(item: index,section: 0)) as? GXAddImageCell
        }
    }

    func showActivityDetailDescAddViewBrowser(pageIndex: Int, cell: GXAddImageCell) {
        HXPhotoPicker.PhotoBrowser.show(pageIndex: pageIndex, transitionalImage: cell.imageView.image) {
            self.activityDetailDescAddView.images.count
        } assetForIndex: {
            self.activityDetailDescAddView.images[$0]
        } transitionAnimator: { index in
            self.activityDetailDescAddView.cellForItem(at: IndexPath(item: index,section: 0)) as? GXAddImageCell
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

    /// 提交审核
    func requestAllSubmitActivityDirect() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestAllSubmitActivityDirect(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.showSubmitSuccessAlert()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func showSubmitSuccessAlert() {
        let title = "提交成功\n平台会在1-2个工作日内审核\n请耐心等待！"
        GXUtil.showAlert(title: title, cancelTitle: "我知道了") { alert, index in
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    /// 编辑提交审核
    func requestEditActivity() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestEditActivity(to: self, step: 4, success: {[weak self] in
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

extension GXPublishStep4VC {

    /// 我同意《产品服务协议》
    @IBAction func activityCheckButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.viewModel.activityAgreementCheck = sender.isSelected
    }
    /// 保存草稿
    @IBAction func activitySaveDraftBtnClicked(_ sender: UIButton) {
        self.viewModel.activityImages = self.activityAddView.images
        self.viewModel.activityDetailImages = self.activityDetailTopAddView.images
        self.viewModel.activityDetailDescImages = self.activityDetailDescAddView.images
        
        self.requestSaveActivityDraft()
    }
    /// 上一步
    @IBAction func activityLastBtnClicked(_ sender: UIButton) {
        self.backBarButtonItemTapped()
    }
    /// 提交审核
    @IBAction func activitySubmitBtnClicked(_ sender: UIButton) {
        self.viewModel.activityImages = self.activityAddView.images
        self.viewModel.activityDetailImages = self.activityDetailTopAddView.images
        self.viewModel.activityDetailDescImages = self.activityDetailDescAddView.images

        let checked = self.viewModel.isEditBaseInfoPage4Checked()
        guard checked else { return }

        if self.viewModel.publishEditType == .detail {
            // 详情编辑时为提交（修改基本资料/图文介绍）
            self.requestEditActivity()
        }
        else {
            // 提交（发布活动）
            self.requestAllSubmitActivityDirect()
        }
    }
    
    @IBAction func showDemo1BtnClicked(_ sender: UIButton) {
        let text = "上传图片后，显示在用户端/活动方端的首页、活动日历、票夹等多处区域。"
        GXPublicDemoView.showAlertView(text: text, imageName: "p_demo1")
    }
    
    @IBAction func showDemo2BtnClicked(_ sender: UIButton) {
        let text = "上传图片后，显示在活动详情页的顶部区域，可左右滑动查看，最多上传9张。"
        GXPublicDemoView.showAlertView(text: text, imageName: "p_demo2")
    }
    
    @IBAction func showDemo3BtnClicked(_ sender: UIButton) {
        let text = "上传图片后，显示在活动详情页的内容区，可向下滑动查看，最多上传9张。"
        GXPublicDemoView.showAlertView(text: text, imageName: "p_demo3")
    }

}

extension GXPublishStep4VC: UITextViewDelegate {
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.didLinkScheme(URL.absoluteString)
        return false
    }
    func didLinkScheme(_ scheme: String) {
        switch scheme {
        case "cpfwxy":
            let urlString = Api_WebBaseUrl + "/h5/#/agreement/3"
            let vc = GXWebViewController(urlString: urlString, title: "产品服务协议")
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
}
