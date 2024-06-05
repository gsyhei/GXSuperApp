//
//  GXPublishMemberVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/8.
//

import UIKit
import GXSegmentPageView
import MBProgressHUD

class GXPublishMemberVC: GXBaseViewController {
    @IBOutlet weak var segmentTitleView: GXSegmentTitleView!
    @IBOutlet weak var pageView: GXSegmentPageView!
    private var activityData: GXActivityBaseInfoData!
    private var selectIndex: Int = 0

    private lazy var config: GXSegmentTitleView.Configuration = {
        return GXSegmentTitleView.Configuration().then {
            $0.positionStyle = .none
            $0.titleNormalFont = .gx_boldFont(size: 15)
            $0.titleSelectedFont = .gx_boldFont(size: 15)
            $0.titleNormalColor = .gx_gray
            $0.titleSelectedColor = .gx_textBlack
            $0.titleFixedWidth = SCREEN_WIDTH/2
            $0.bottomLineColor = .gx_lightGray
            $0.bottomLineHeight = 0.5
            $0.isTitleZoom = false
        }
    }()

    private lazy var addButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.contentHorizontalAlignment = .right
            $0.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 44))
            $0.setTitle("添加工作人员", for: .normal)
            $0.setTitleColor(.gx_black, for: .normal)
            $0.setTitleColor(.gx_lightGray, for: .highlighted)
            $0.titleLabel?.font = .gx_font(size: 15)
            $0.setImage(UIImage(named: "aw_add"), for: .normal)
            $0.addTarget(self, action: #selector(self.rightButtonItemTapped), for: .touchUpInside)
        }
    }()

    private lazy var scanButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.contentHorizontalAlignment = .right
            $0.frame = CGRect(origin: .zero, size: CGSize(width: 64, height: 44))
            $0.setTitle("扫一扫", for: .normal)
            $0.setTitleColor(.gx_black, for: .normal)
            $0.setTitleColor(.gx_lightGray, for: .highlighted)
            $0.titleLabel?.font = .gx_font(size: 15)
            $0.setImage(UIImage(named: "a_qrcode"), for: .normal)
            $0.imageLocationAdjust(model: .left, spacing: 2.0)
            $0.addTarget(self, action: #selector(self.scanButtonItemTapped), for: .touchUpInside)
        }
    }()

    private lazy var childVCs: [UIViewController] = {
        var children: [UIViewController] = []
        children.append(GXPublishMemberWorkerVC.createVC(viewModel: self.viewModel))
        children.append(GXPublishMemberSignUpVC.createVC(viewModel: self.viewModel))
        return children
    }()

    private var viewModel: GXPublishMemberViewModel = {
        return GXPublishMemberViewModel()
    }()

    class func createVC(activityData: GXActivityBaseInfoData, selectIndex: Int = 0) -> GXPublishMemberVC {
        return GXPublishMemberVC.xibViewController().then {
            $0.viewModel.activityData = activityData
            $0.selectIndex = selectIndex
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "编辑成员"
        self.gx_addBackBarButtonItem()

        if GXRoleUtil.isAdmin(roleType: self.viewModel.activityData.roleType) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.addButton)
        }
        self.segmentTitleView.setupSegmentTitleView(config: self.config, titles: ["工作人员", "报名用户"])
        self.segmentTitleView.delegate = self

        self.pageView.collectionView.isScrollEnabled = false
        self.pageView.collectionView.backgroundColor = .white
        self.pageView.setupSegmentPageView(parent: self, children: self.childVCs)
        self.pageView.delegate = self

        self.view.layoutIfNeeded()
        self.segmentTitleView.setSelectIndex(at: self.selectIndex)
        self.pageView.scrollToItem(to: self.selectIndex, animated: false)
    }
}

extension GXPublishMemberVC: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
        if index == 0 {
            guard GXRoleUtil.isAdmin(roleType: self.viewModel.activityData.roleType) else { return }
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.addButton)
        } else {
            guard GXRoleUtil.isTeller(roleType: self.viewModel.activityData.roleType) else { return }
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.scanButton)
        }
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        self.segmentTitleView.setSegmentTitleView(selectIndex: page.selectedIndex, willSelectIndex: page.willSelectedIndex, progress: progress)
    }
}

extension GXPublishMemberVC: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: true)
    }
}

extension GXPublishMemberVC {

    func requestAddActivityStaff(phone: String, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        MBProgressHUD.showLoading()
        self.viewModel.requestAddActivityStaff(phone: phone, success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss()
            GXToast.showSuccess(text: "添加成功")
            self.updateAddActivityStaff()
            success()
        }) { error in
            MBProgressHUD.dismiss()
            failure(error)
        }
    }

    func updateAddActivityStaff() {
        if let vc = self.childVCs.first as? GXPublishMemberWorkerVC {
            vc.requestRefreshData()
        }
    }

    func updateAddActivitySignUsers() {
        if let vc = self.childVCs.last as? GXPublishMemberSignUpVC {
            vc.requestGetActivitySignInfo()
        }
    }
}

extension GXPublishMemberVC {

    @objc func rightButtonItemTapped() {
        GXUtil.showInputAlert(title: "添加工作人员", placeholder: "请输入手机号") { alert, index in
            guard index > 0 else { return }
            guard let text = alert.inputs.first?.inputText.value, text.count == 11 else {
                alert.infoLabel.text = "请输入11位手机号"
                return
            }
            self.requestAddActivityStaff(phone: text) {
                alert.hide(animated: true)
            } failure: { error in
                alert.infoLabel.text = error.localizedDescription
            }
        }
    }

    @objc func scanButtonItemTapped() {
        let vc = GXQRCodeReaderVC.xibViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.didFindCodeAction = {[weak self] (type, value, qrVC) in
            guard let `self` = self else { return }
            switch type {
            case .url:
                qrVC.dismiss(animated: true)
                let vc = GXWebViewController(urlString: value, title: "")
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case .user:
                qrVC.dismiss(animated: true)
                GXMinePtOtherVC.push(fromVC: self, userId: value)
            case .event:
                qrVC.dismiss(animated: true)
                GXToast.showError(text: "此为事件二维码，请切换至用户端参与！")
            case .ticket:
                GXApiUtil.requestActivityVerifyTicket(ticketCode: value, completion: {
                    qrVC.reader.startScanning()
                })
            case .activity:
                qrVC.dismiss(animated: true)
                GXToast.showError(text: "此为活动二维码，请切换至用户端参与！")
            default:
                qrVC.dismiss(animated: true)
                GXToast.showError(text: "未能识别\n" + value)
            }
        }
        self.present(vc, animated: true)
    }
}
