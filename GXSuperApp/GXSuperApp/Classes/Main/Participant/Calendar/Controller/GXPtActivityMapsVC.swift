//
//  GXPtActivityMapsVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/2.
//

import UIKit
import HXPhotoPicker
import MBProgressHUD

class GXPtActivityMapsVC: GXBaseViewController {

    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .white
            $0.separatorStyle = .none
            $0.dataSource = self
            $0.delegate = self
            $0.placeholder = "暂无场地图"
            $0.register(cellType: GXPublishActivityDetailPicCell.self)
            $0.register(headerFooterViewType: GXPtEventDetailPicsHeader.self)
        }
    }()

    var activityId: Int = 0
    var mapImages: [PhotoAsset] = []
    var mapInfoData: GXActivityMapInfoData? {
        didSet {
            guard let data = mapInfoData else { return }
            self.mapImages = PhotoAsset.gx_photoAssets(pics: data.mapPics)
        }
    }

    required init(activityId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.activityId = activityId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetActivityMapInfo()
        GXApiUtil.requestCreateEvent(targetType: 11, activityId: self.activityId)
    }

    override func setupViewController() {
        self.title = "地图"
        self.gx_addBackBarButtonItem()

        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension GXPtActivityMapsVC {
    func requestGetActivityMapInfo() {
        MBProgressHUD.showLoading(to: self.view)
        let api = GXApi.normalApi(Api_CActivity_GetActivityMapInfo, ["id":self.activityId], .get)
        GXNWProvider.login_request(api, type: GXActivityMapInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            self.mapInfoData = model.data
            self.tableView.gx_reloadData()
            MBProgressHUD.dismiss(for: self.view)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXPtActivityMapsVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mapImages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPublishActivityDetailPicCell = tableView.dequeueReusableCell(for: indexPath)
        let photoAsset = self.mapImages[indexPath.row]
        cell.bindModel(asset: photoAsset) {[weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(GXPtEventDetailPicsHeader.self)
        header?.bindView(text: self.mapInfoData?.mapDesc, isShowLine: false)

        return header
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 100.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GXPublishActivityDetailPicCell.height(asset: self.mapImages[indexPath.row])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? GXPublishActivityDetailPicCell else { return }

        HXPhotoPicker.PhotoBrowser.show(pageIndex: indexPath.row, transitionalImage: cell.picImageView.image) {
            self.mapImages.count
        } assetForIndex: {
            self.mapImages[$0]
        } transitionAnimator: { index in
            let curIndexPath = IndexPath(row: index, section: indexPath.section)
            let cell = tableView.cellForRow(at: curIndexPath) as? GXPublishActivityDetailPicCell
            return cell?.picImageView
        }
    }
}

