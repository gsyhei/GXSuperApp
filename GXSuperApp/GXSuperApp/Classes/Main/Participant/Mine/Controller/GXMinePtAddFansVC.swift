//
//  GXPublishMemberVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/8.
//

import UIKit
import GXSegmentPageView
import MBProgressHUD

class GXMinePtAddFansVC: GXBaseViewController {
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

    private lazy var childVCs: [UIViewController] = {
        var children: [UIViewController] = []
        children.append(GXMinePtAddFansPageVC(selectIndex: 0))
        children.append(GXMinePtAddFansPageVC(selectIndex: 1))
        return children
    }()

    private var titles: [String] = {
        return ["我的粉丝", "我的关注"]
    }()

    class func createVC(selectIndex: Int = 0) -> GXMinePtAddFansVC {
        return GXMinePtAddFansVC.xibViewController().then {
            $0.selectIndex = selectIndex
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.gx_addBackBarButtonItem()
        self.title = "我的好友"

        self.segmentTitleView.setupSegmentTitleView(config: self.config, titles: self.titles)
        self.segmentTitleView.delegate = self

        self.pageView.collectionView.isScrollEnabled = true
        self.pageView.collectionView.backgroundColor = .white
        self.pageView.setupSegmentPageView(parent: self, children: self.childVCs)
        self.pageView.delegate = self

        self.view.layoutIfNeeded()
        self.segmentTitleView.setSelectIndex(at: self.selectIndex)
        self.pageView.scrollToItem(to: self.selectIndex, animated: false)
    }
}

extension GXMinePtAddFansVC: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        self.segmentTitleView.setSegmentTitleView(selectIndex: page.selectedIndex, willSelectIndex: page.willSelectedIndex, progress: progress)
    }
}

extension GXMinePtAddFansVC: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: true)
    }
}
