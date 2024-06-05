//
//  GXParticipantHomeVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/5.
//

import UIKit
import GXSegmentPageView

class GXParticipantHomeVC: GXBaseWarnViewController {
    @IBOutlet weak var segmentTitleView: GXSegmentTitleView!
    @IBOutlet weak var pageView: GXSegmentPageView!

    lazy var config: GXSegmentTitleView.Configuration = {
        return GXSegmentTitleView.Configuration().then {
            $0.titleNormalFont = .gx_boldFont(size: 16)
            $0.positionStyle = .center
            $0.indicatorStyle = .dynamic
            $0.indicatorColor = .gx_textBlack
            $0.indicatorCornerRadius = 13.0
            $0.indicatorFixedWidth = 44.0
            $0.indicatorFixedHeight = 26.0
            $0.titleFixedWidth = 50.0
            $0.titleSelectedColor = .white
            $0.isShowBottomLine = false
            $0.isShowSeparator = false
            $0.isTitleZoom = false
        }
    }()

    private lazy var childVCs: [UIViewController] = {
        var children: [UIViewController] = []
        children.append(GXParticipantHomeFindVC.xibViewController())
        children.append(GXParticipantHomeAttentionVC.xibViewController())
        return children
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

        NotificationCenter.default.rx
            .notification(GX_NotifName_Login)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.reloadViewData()
            }).disposed(by: disposeBag)
        NotificationCenter.default.rx
            .notification(GX_NotifName_NetworkStatus)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.showNotReachableWarning()
            }).disposed(by: disposeBag)
    }

    override func setupViewController() {
        self.segmentTitleView.setupSegmentTitleView(config: self.config, titles: ["发现", "关注"])
        self.segmentTitleView.delegate = self

        self.pageView.collectionView.isScrollEnabled = false
        self.pageView.collectionView.backgroundColor = .clear
        self.pageView.setupSegmentPageView(parent: self, children: self.childVCs)
        self.pageView.delegate = self
    }

    func reloadViewData() {
        if self.pageView.selectedIndex == 0 {
            let vc = self.childVCs.first as? GXParticipantHomeFindVC
            vc?.requestGetAllData()
        }
    }

    func showNotReachableWarning() {
        if GXServiceManager.shared.networkStatus == .notReachable {
            GXMusicPlayerManager.shared.playMusicPlayer(isPlay: false)
            self.gx_showWarning(text: "当前网络不可用，请检查您的网络设置",
                                topView: self.segmentTitleView,
                                constant: 8,
                                augmentHeight: 8)
        } else {
            self.gx_hideWarning()
            if self.pageView.selectedIndex == 0 {
                let vc = self.childVCs.first as? GXParticipantHomeFindVC
                if vc?.viewModel.dtSectionList.count == 0 {
                    vc?.requestGetAllData()
                }
            }
        }
    }
}

extension GXParticipantHomeVC: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
        if index == 1 {
            GXApiUtil.requestCreateEvent(targetType: 7)
        }
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        self.segmentTitleView.setSegmentTitleView(selectIndex: page.selectedIndex, willSelectIndex: page.willSelectedIndex, progress: progress)
    }
}

extension GXParticipantHomeVC: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: false)
    }
}
