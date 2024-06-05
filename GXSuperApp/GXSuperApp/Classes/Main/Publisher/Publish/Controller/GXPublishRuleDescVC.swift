//
//  GXPublishRuleDescVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/8.
//

import UIKit
import MBProgressHUD
import GXSegmentPageView

class GXPublishRuleDescVC: GXBaseViewController {
    @IBOutlet weak var segmentTitleView: GXSegmentTitleView!
    @IBOutlet weak var pageView: GXSegmentPageView!

    private lazy var titles: [String] = {
        return ["买票规则", "报名规则"]
    }()
    private lazy var childVCs: [UIViewController] = {
        var children: [UIViewController] = []
        children.append(GXWebViewController(urlString: Api_WebBaseUrl + "/h5/#/agreement/1"))
        children.append(GXWebViewController(urlString: Api_WebBaseUrl + "/h5/#/agreement/2"))
        return children
    }()
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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "规则说明"
        self.gx_addBackBarButtonItem()

        self.segmentTitleView.setupSegmentTitleView(config: self.config, titles: self.titles)
        self.segmentTitleView.delegate = self

        self.pageView.collectionView.backgroundColor = .white
        self.pageView.setupSegmentPageView(parent: self, children: self.childVCs)
        self.pageView.delegate = self
    }

}

extension GXPublishRuleDescVC: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        self.segmentTitleView.setSegmentTitleView(selectIndex: page.selectedIndex, willSelectIndex: page.willSelectedIndex, progress: progress)
    }
}

extension GXPublishRuleDescVC: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: true)
    }
}
