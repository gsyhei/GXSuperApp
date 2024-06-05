//
//  GXParticipantHomeMysignVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/13.
//

import UIKit
import GXSegmentPageView
import MBProgressHUD

class GXParticipantHomeMysignVC: GXBaseViewController {
    @IBOutlet weak var segmentTitleView: GXSegmentTitleView!
    @IBOutlet weak var pageView: GXSegmentPageView!
    var mySignActivityData: GXPtHomeMySignActivityData!
    var selectedIndex: Int = 0

    private lazy var config: GXSegmentTitleView.Configuration = {
        return GXSegmentTitleView.Configuration().then {
            $0.positionStyle = .none
            $0.titleNormalFont = .gx_boldFont(size: 15)
            $0.titleSelectedFont = .gx_boldFont(size: 15)
            $0.titleNormalColor = .gx_gray
            $0.titleSelectedColor = .gx_textBlack
            $0.titleFixedWidth = SCREEN_WIDTH/CGFloat(self.titles.count)
            $0.bottomLineColor = .gx_lightGray
            $0.bottomLineHeight = 0.5
            $0.isTitleZoom = false
        }
    }()

    private lazy var childVCs: [UIViewController] = {
        var children: [UIViewController] = []
        children.append(GXParticipantHomeMysignListVC(list: self.mySignActivityData.goingActivityList))
        children.append(GXParticipantHomeMysignListVC(list: self.mySignActivityData.notStartActivityList))
        return children
    }()

    private lazy var titles: [String] = {
        return ["进行中", "未开始"]
    }()

    class func createVC(data: GXPtHomeMySignActivityData, index: Int) -> GXParticipantHomeMysignVC {
        return GXParticipantHomeMysignVC.xibViewController().then {
            $0.mySignActivityData = data
            $0.selectedIndex = index
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "我报名的活动"
        self.gx_addNavTopView(color: .white)
        self.gx_addBackBarButtonItem()

        self.segmentTitleView.setupSegmentTitleView(config: self.config, titles: self.titles)
        self.segmentTitleView.delegate = self

        self.pageView.collectionView.isScrollEnabled = true
        self.pageView.collectionView.backgroundColor = .white
        self.pageView.setupSegmentPageView(parent: self, children: self.childVCs)
        self.pageView.delegate = self

        self.view.layoutIfNeeded()
        self.segmentTitleView.setSelectIndex(at: self.selectedIndex)
        self.pageView.scrollToItem(to: self.selectedIndex, animated: false)
    }

}

extension GXParticipantHomeMysignVC: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        self.segmentTitleView.setSegmentTitleView(selectIndex: page.selectedIndex, willSelectIndex: page.willSelectedIndex, progress: progress)
    }
}

extension GXParticipantHomeMysignVC: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: true)
    }
}
