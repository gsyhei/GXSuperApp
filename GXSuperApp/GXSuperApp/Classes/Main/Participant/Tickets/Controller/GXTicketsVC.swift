//
//  GXTicketsVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/6.
//

import UIKit
import GXSegmentPageView

class GXTicketsVC: GXBaseViewController {
    @IBOutlet weak var pageView: GXSegmentPageView!
    @IBOutlet weak var segmentTitleView: GXSegmentTitleView!

    private lazy var config: GXSegmentTitleView.Configuration = {
        return GXSegmentTitleView.Configuration().then {
            $0.indicatorColor = .gx_green
            $0.indicatorFixedHeight = 7.0
            $0.indicatorFixedWidth = 52.0
            $0.indicatorMargin = 10
            $0.titleNormalFont = .gx_font(size: 15)
            $0.titleSelectedFont = .gx_boldFont(size: 18)
            $0.titleNormalColor = .gx_drakGray
            $0.titleSelectedColor = .gx_black
            $0.titleFixedWidth = 70
            $0.bottomLineColor = .gx_lightGray
            $0.isShowBottomLine = false
            $0.isTitleZoom = false
        }
    }()

    private lazy var childVCs: [UIViewController] = {
        var children: [UIViewController] = []
        children.append(GXTicketsListVC(ticketStatus: 0, isAllOpen: true))
        children.append(GXTicketsListVC(ticketStatus: 1, isAllOpen: false))
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
    }

    override func setupViewController() {
        self.segmentTitleView.setupSegmentTitleView(config: self.config, titles: ["未使用", "已使用"])
        self.segmentTitleView.delegate = self

        self.pageView.collectionView.backgroundColor = .gx_background
        self.pageView.setupSegmentPageView(parent: self, children: self.childVCs)
        self.pageView.delegate = self
    }
}

extension GXTicketsVC: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        self.segmentTitleView.setSegmentTitleView(selectIndex: page.selectedIndex, willSelectIndex: page.willSelectedIndex, progress: progress)
    }
}

extension GXTicketsVC: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: true)
    }
}
