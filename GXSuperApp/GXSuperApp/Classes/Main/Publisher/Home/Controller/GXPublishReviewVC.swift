//
//  GXPublishHomeVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/8.
//

import UIKit
import GXSegmentPageView
import MBProgressHUD

class GXPublishReviewVC: GXBaseViewController {
    @IBOutlet weak var segmentTitleView: GXSegmentTitleView!
    @IBOutlet weak var pageView: GXSegmentPageView!
    private var activityId: Int = 0
    private var selectIndex: Int = 0
    private var roleType: String?

    private lazy var config: GXSegmentTitleView.Configuration = {
        return GXSegmentTitleView.Configuration().then {
            $0.indicatorColor = .gx_green
            $0.indicatorFixedHeight = 3.0
            $0.indicatorFixedWidth = 30.0
            $0.titleNormalFont = .gx_boldFont(size: 15)
            $0.titleSelectedFont = .gx_boldFont(size: 15)
            $0.titleNormalColor = .gx_gray
            $0.titleSelectedColor = .gx_textBlack
            $0.titleFixedWidth = SCREEN_WIDTH/3
            $0.bottomLineColor = .gx_lightGray
            $0.bottomLineHeight = 0.5
            $0.isTitleZoom = false
        }
    }()

    private lazy var addButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.contentHorizontalAlignment = .right
            $0.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 44))
            $0.setTitle("添加回顾", for: .normal)
            $0.setTitleColor(.gx_black, for: .normal)
            $0.setTitleColor(.gx_lightGray, for: .highlighted)
            $0.titleLabel?.font = .gx_font(size: 15)
            $0.setImage(UIImage(named: "aw_add"), for: .normal)
            $0.addTarget(self, action: #selector(self.rightButtonItemTapped), for: .touchUpInside)
        }
    }()

    private lazy var childVCs: [UIViewController] = {
        var children: [UIViewController] = []
        children.append(GXPublishReviewListVC(activityId: self.activityId, reviewStatus: 1))
        children.append(GXPublishReviewListVC(activityId: self.activityId, reviewStatus: 0))
        children.append(GXPublishReviewListVC(activityId: self.activityId, reviewStatus: 2))
        return children
    }()

    class func createVC(activityId: Int, roleType: String? = nil, selectIndex: Int = 0) -> GXPublishReviewVC {
        return GXPublishReviewVC.xibViewController().then {
            $0.activityId = activityId
            $0.roleType = roleType
            $0.selectIndex = selectIndex
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "回顾"
        self.gx_addBackBarButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.addButton)

        self.segmentTitleView.setupSegmentTitleView(config: self.config, titles: ["已启用", "待审核", "已禁用"])
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

extension GXPublishReviewVC: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        self.segmentTitleView.setSegmentTitleView(selectIndex: page.selectedIndex, willSelectIndex: page.willSelectedIndex, progress: progress)
    }
}

extension GXPublishReviewVC: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: true)
    }
}

extension GXPublishReviewVC {

    @objc func rightButtonItemTapped() {
        let vc = GXPublishReviewEidtVC.createVC(activityId: self.activityId, roleType: self.roleType)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
