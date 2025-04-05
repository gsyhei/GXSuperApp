//
//  GXMineVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import SkeletonView
import PromiseKit
import HXPhotoPicker
import MBProgressHUD

class GXMineVC: GXBaseViewController {
    @IBOutlet weak var topBgHeightLC: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(estimated: true, separatorLeft: false)
            tableView.separatorStyle = .none
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 80))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.sectionHeaderHeight = .leastNormalMagnitude
            tableView.sectionFooterHeight = 12.0
            tableView.register(cellType: GXMineInfoCell.self)
            tableView.register(cellType: GXMineCell1.self)
            tableView.register(cellType: GXMineCell2.self)
            tableView.register(cellType: GXMineCell3.self)
        }
    }
    
    private lazy var viewModel: GXMineViewModel = {
        return GXMineViewModel()
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestOrderConsumerDetail()
    }
    
    override func viewDidAppearForAfterLoading() {
        self.requestOrderConsumerDetail(isShowHud: false)
    }
    
    override func setupViewController() {
        self.view.backgroundColor = .gx_background
    }
    
    func updateDataSource() {
        self.viewModel.updateConfigCellIndexs()
        self.tableView.reloadData()
    }
}

private extension GXMineVC {
    func requestOrderConsumerDetail(isShowHud: Bool = true) {
        if isShowHud {
            self.view.showAnimatedGradientSkeleton()
        }
        let combinedPromise = when(fulfilled: [
            self.viewModel.requestParamConsumer(),
            self.viewModel.requestWalletConsumerBalance(),
            self.viewModel.requestOrderConsumerTotal(),
            GXNWProvider.login_requestUserInfo()
        ])
        firstly {
            combinedPromise
        }.done { models in
            self.view.hideSkeleton()
            self.updateDataSource()
        }.catch { error in
            self.view.hideSkeleton()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func requestUploadAvatar(asset: PhotoAsset) {
        MBProgressHUD.showLoading()
        firstly {
            GXNWProvider.login_requestUpload(asset: asset)
        }.then { model in
            self.viewModel.requestAuthUserProfileEdit(photo: model?.data?.path ?? "")
        }.done { photo in
            MBProgressHUD.dismiss()
            GXUserManager.shared.user?.photo = photo
            self.tableView.reloadData()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
}

extension GXMineVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    // MARK - SkeletonTableViewDataSource
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 4
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        switch indexPath.section {
        case 0:
            return GXMineInfoCell.reuseIdentifier        
        case 1:
            return GXMineCell1.reuseIdentifier
        case 2:
            return GXMineCell2.reuseIdentifier
        case 3:
            return GXMineCell3.reuseIdentifier
        default:
            return ""
        }
    }
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        switch indexPath.section {
        case 0:
            let cell: GXMineInfoCell = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 1:
            let cell: GXMineCell1 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell        
        case 2:
            let cell: GXMineCell2 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 3:
            let cell: GXMineCell3 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.cellIndexs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = self.viewModel.cellIndexs[indexPath.section]
        switch index {
        case 0:
            let cell: GXMineInfoCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: GXUserManager.shared.user) {[weak self] in
                guard let `self` = self else { return }
                self.selectAvatarUpload()
            }
            return cell
        case 1:
            let cell: GXMineCell1 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(data: self.viewModel.balanceData, orderTotal: self.viewModel.orderTotal) {[weak self] index in
                guard let `self` = self else { return }
                if index == 0 {
                    let vc = GXMineWalletVC.createVC(balanceData: self.viewModel.balanceData)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    let vc = GXOrderListVC.xibViewController()
                    vc.gx_addBackBarButtonItem()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            return cell
        case 2:
            let cell: GXMineCell2 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(models: self.viewModel.cell2Models) {[weak self] index in
                guard let `self` = self else { return }
                self.selectToItemsAtIndex(index: index)
            }
            return cell
        case 3:
            let cell: GXMineCell3 = tableView.dequeueReusableCell(for: indexPath)
            cell.updateVipCell(action: {[weak self] in
                guard let `self` = self else { return }
                let vc = GXVipVC.xibViewController()
                vc.gx_addBackBarButtonItem()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            return cell
        default: return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = self.viewModel.cellIndexs[indexPath.section]
        switch index {
        case 0: return 224
        case 1: return 80
        case 2: return 180
        case 3: return 72
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = self.viewModel.cellIndexs[indexPath.section]
        switch index {
        case 0: return 224
        case 1: return 80
        case 2: return 180
        case 3: return 72
        default: return 0
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        if offset.y < 0 {
            self.topBgHeightLC.constant = 334 + abs(offset.y)
        }
    }
    
}

private extension GXMineVC {
    func selectAvatarUpload() {
        var cameraConfig = CameraConfiguration()
        cameraConfig.modalPresentationStyle = .fullScreen
        cameraConfig.allowsEditing = true
        cameraConfig.prefersStatusBarHidden = false
        cameraConfig.cameraType = .metal
        cameraConfig.tintColor = .systemBlue
        cameraConfig.editor.isFixedCropSizeState = true
        cameraConfig.editor.cropSize.isRoundCrop = false
        cameraConfig.editor.cropSize.aspectRatios = []
        cameraConfig.editor.cropSize.aspectRatio = CGSize(width: 1, height: 1)
        cameraConfig.editor.cropSize.isFixedRatio = true
        cameraConfig.editor.cropSize.isResetToOriginal = false
        var config: PickerConfiguration = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.photoList.cameraType = .custom(cameraConfig)
        config.selectMode = .single
        config.selectOptions = .photo
        config.photoSelectionTapAction = .openEditor
        config.photoList.allowAddCamera = true
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoList.rowNumber = 3
        config.editor.isFixedCropSizeState = true
        config.editor.cropSize.isRoundCrop = false
        config.editor.cropSize.aspectRatios = []
        config.editor.cropSize.aspectRatio = CGSize(width: 1, height: 1)
        config.editor.cropSize.isFixedRatio = true
        config.editor.cropSize.isResetToOriginal = false
        let vc = PhotoPickerController.init(config: config)
        vc.finishHandler = {[weak self] (result, picker) in
            guard let `self` = self else { return }
            guard let asset = result.photoAssets.first else { return }
            self.requestUploadAvatar(asset: asset)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func selectToItemsAtIndex(index: Int) {
        switch index {
        case 0:
            let vc = GXMineFavoriteVC.xibViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = GXHomeDetailVehicleVC.xibViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = GXMineAgreementVC.xibViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = GXMinePayManagerVC.xibViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 4:
            let vc = GXMineFAQVC.xibViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 5:
            let vc = GXWebViewController(urlString: GXUtil.gx_h5Url(id: 11), title: "Contact Us")
            self.navigationController?.pushViewController(vc, animated: true)
        case 6:
            let vc = GXMineSettingVC.xibViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
    
}
