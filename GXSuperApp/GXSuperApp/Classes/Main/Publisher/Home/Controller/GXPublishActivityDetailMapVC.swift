//
//  GXPublishActivityDetailMapVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/16.
//

import UIKit
import RxCocoaPlus
import HXPhotoPicker
import MBProgressHUD

class GXPublishActivityDetailMapVC: GXBaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    /// 活动地图描述
    @IBOutlet weak var mapDescTextView: GXTextView!
    @IBOutlet weak var mapDescNumLabel: UILabel!

    /// 活动地图图片-最大9张
    @IBOutlet weak var mapAddView: GXAddImagesView!
    @IBOutlet weak var mapAddViewHLC: NSLayoutConstraint!
    /// 保存/提交
    @IBOutlet weak var saveButton: UIButton!

    private lazy var viewModel: GXPublishActivityDetailMapViewModel = {
        return GXPublishActivityDetailMapViewModel()
    }()

    class func createVC(activityData: GXActivityBaseInfoData) -> GXPublishActivityDetailMapVC {
        return GXPublishActivityDetailMapVC.xibViewController().then {
            $0.viewModel.activityData = activityData
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetActivityMapInfo()
    }

    override func setupViewController() {
        self.title = "地图"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.saveButton.setBackgroundColor(.gx_green, for: .normal)
        self.mapDescTextView.font = .gx_font(size: 16)
        self.mapDescTextView.placeholder = "输入描述信息"
        self.mapDescTextView.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.mapDescTextView.markedTextRange == nil else { return }
            guard var text = self.mapDescTextView.text else { return }
            let maxCount: Int = 5000
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.mapDescTextView.text = text
            }
            self.mapDescNumLabel.text = "\(text.count)/\(maxCount)"
            self.mapDescNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        // Bind input
        (self.mapDescTextView.rx.textInput <-> self.viewModel.mapDescInput).disposed(by: disposeBag)

        self.mapAddView.backgroundColor = .clear
        self.mapAddView.maxAddCount = 9
        self.mapAddView.closeAction = {[weak self] height in
            self?.mapAddViewHLC.constant = height
        }
        self.mapAddView.addAction = {[weak self] in
            self?.showMapAddViewPhotoPicker()
        }
        self.mapAddView.previewAction = {[weak self] (index, cell) in
            self?.showMapAddViewBrowser(pageIndex: index, cell: cell)
        }

        if !GXRoleUtil.isAdmin(roleType: self.viewModel.activityData.roleType) {
            self.contentView.isUserInteractionEnabled = false
            self.saveButton.gx_setDisabledButton()
        }
    }

}

extension GXPublishActivityDetailMapVC {
    func requestGetActivityMapInfo() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetActivityMapInfo(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.mapAddView.images = self.viewModel.mapImages
            self.mapAddViewHLC.constant = self.mapAddView.getShowHeight()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestUpdateActivityMapInfo() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestUpdateActivityMapAll(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showSuccess(text: "保存成功", to: self?.view)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXPublishActivityDetailMapVC {

    func showMapAddViewPhotoPicker() {
        var config: PickerConfiguration = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.selectMode = .multiple
        config.selectOptions = .photo
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoSelectionTapAction = .openEditor
        config.photoList.rowNumber = 3
        config.maximumSelectedCount = (9 - self.mapAddView.images.count)
        let vc = PhotoPickerController.init(config: config)
        vc.finishHandler = {[weak self] (result, picker) in
            self?.mapAddView.images.append(contentsOf: result.photoAssets)
            self?.viewModel.mapImages = self?.mapAddView.images ?? []
            self?.mapAddViewHLC.constant = self?.mapAddView.getShowHeight() ?? 0
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func showMapAddViewBrowser(pageIndex: Int, cell: GXAddImageCell) {
        HXPhotoPicker.PhotoBrowser.show(pageIndex: pageIndex, transitionalImage: cell.imageView.image) {
            self.mapAddView.images.count
        } assetForIndex: {
            self.mapAddView.images[$0]
        } transitionAnimator: { index in
            self.mapAddView.cellForItem(at: IndexPath(item: index,section: 0)) as? GXAddImageCell
        }
    }

    @IBAction func saveButtonClicked(_ sender: UIButton) {
        self.viewModel.mapImages = self.mapAddView.images
        self.requestUpdateActivityMapInfo()
    }

}
