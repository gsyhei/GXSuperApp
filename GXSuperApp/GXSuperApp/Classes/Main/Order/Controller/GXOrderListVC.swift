//
//  GXOrderListVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/9.
//

import UIKit
import GXSegmentPageView

class GXOrderListVC: GXBaseViewController {
    @IBOutlet weak var segmentTitleView: GXSegmentTitleView!
    @IBOutlet weak var pageView: GXSegmentPageView!
    
    private lazy var indicator: UIImageView = {
        let colors: [UIColor] = [.gx_green, .gx_blue]
        let image = UIImage(gradientColors: colors, style: .horizontal, size: CGSize(width: 24, height: 3))
        return UIImageView(image: image).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }()
    
    private lazy var config: GXSegmentTitleView.Configuration = {
        return GXSegmentTitleView.Configuration().then {
            $0.titleMargin = 12.0
            $0.titleNormalFont = .gx_font(size: 16)
            $0.titleSelectedFont = .gx_boldFont(size: 16)
            $0.titleNormalColor = .gx_drakGray
            $0.titleSelectedColor = .gx_textBlack
            $0.bottomLineColor = .gx_lightGray
            $0.bottomLineHeight = 0.5
            $0.indicatorFixedWidth = 24.0
            $0.indicatorFixedHeight = 3.0
            $0.indicatorCornerRadius = 1.5
            $0.isTitleZoom = false
        }
    }()

    private lazy var childVCs: [UIViewController] = {
        var children: [UIViewController] = []
        // 订单状态；CHARGING：充电中，OCCUPY：占位中，TO_PAY：待支付，FINISHED：已完成
        children.append(GXOrderListTypeVC(orderStatus: nil))
        children.append(GXOrderListTypeVC(orderStatus: "CHARGING"))
        children.append(GXOrderListTypeVC(orderStatus: "OCCUPY"))
        children.append(GXOrderListTypeVC(orderStatus: "TO_PAY"))
        children.append(GXOrderListTypeVC(orderStatus: "FINISHED"))
        return children
    }()

    private lazy var titles: [String] = {
        return ["All", "Charging", "Occupied", "Unpaid", "Completed"]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.navigationItem.title = "Order"

        self.segmentTitleView.setupSegmentTitleView(config: self.config, titles: self.titles)
        self.segmentTitleView.delegate = self
        self.segmentTitleView.indicator.masksToBounds = true
        self.indicator.frame = self.segmentTitleView.indicator.bounds
        self.segmentTitleView.indicator.addSubview(self.indicator)

        self.pageView.collectionView.isScrollEnabled = true
        self.pageView.collectionView.backgroundColor = .white
        self.pageView.setupSegmentPageView(parent: self, children: self.childVCs)
        self.pageView.delegate = self
    }

}

extension GXOrderListVC: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        self.segmentTitleView.setSegmentTitleView(selectIndex: page.selectedIndex, willSelectIndex: page.willSelectedIndex, progress: progress)
    }
}

extension GXOrderListVC: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: true)
    }
}

