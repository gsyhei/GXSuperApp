//
//  GXConversationListVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/13.
//

import UIKit
import GXSegmentPageView
import MBProgressHUD

class GXConversationListVC: GXBaseViewController {
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
            $0.titleFixedWidth = SCREEN_WIDTH/CGFloat(self.titles.count)
            $0.bottomLineColor = .gx_lightGray
            $0.bottomLineHeight = 0.5
            $0.isTitleZoom = false
        }
    }()

    private lazy var childVCs: [UIViewController] = {
        // 消息tab 1-活动咨询(参与端) 2-活动咨询(发布端) 3-报名群(参与端) 4-报名群(发布端) 5-工作群(发布端)
        var children: [UIViewController] = []
        if GXUserManager.shared.roleType == .publisher {
            children.append(GXConversationUsersListVC(messageType: 2))
            children.append(GXConversationUsersListVC(messageType: 4))
            children.append(GXConversationUsersListVC(messageType: 5))
            children.append(GXConversationSystemListVC())
        }
        else {
            children.append(GXConversationUsersListVC(messageType: 1))
            children.append(GXConversationUsersListVC(messageType: 3))
            children.append(GXConversationSystemListVC())
        }
        return children
    }()

    private lazy var titles: [String] = {
        if GXUserManager.shared.roleType == .publisher {
            return ["活动咨询", "报名群", "工作群", "系统消息"]
        }
        else {
            return ["活动咨询", "报名群", "系统消息"]
        }
    }()

    private lazy var redPointViews: [UIView] = {
        var pointViews: [UIView] = []
        for _ in self.titles {
            let point = UIView(frame: CGRect(origin: .zero, size: CGSizeMake(6, 6))).then {
                $0.backgroundColor = .gx_red
                $0.layer.masksToBounds = true
                $0.layer.cornerRadius = 3.0
                $0.isHidden = true
            }
            pointViews.append(point)
        }
        return pointViews
    }()

    class func createVC(selectIndex: Int = 0) -> GXConversationListVC {
        return GXConversationListVC.xibViewController().then {
            $0.selectIndex = selectIndex
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        GXApiUtil.requestGetTabRedPoint()
        NotificationCenter.default.rx
            .notification(GX_NotifName_UpdateTabRedPoint)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.updateSegmentTitleViewRedPoint()
            }).disposed(by: disposeBag)
    }

    override func setupViewController() {
        self.title = "消息"
        self.segmentTitleView.setupSegmentTitleView(config: self.config, titles: self.titles)
        self.segmentTitleView.delegate = self

        self.pageView.collectionView.isScrollEnabled = false
        self.pageView.collectionView.backgroundColor = .white
        self.pageView.setupSegmentPageView(parent: self, children: self.childVCs)
        self.pageView.delegate = self

        self.view.layoutIfNeeded()
        self.segmentTitleView.setSelectIndex(at: self.selectIndex)
        self.pageView.scrollToItem(to: self.selectIndex, animated: false)

        self.appendPointViews()
    }

    func appendPointViews() {
        let itemWidth = self.config.titleFixedWidth
        let top = (self.segmentTitleView.height - self.config.titleNormalFont.lineHeight)/2 - 4
        for index in 0..<self.titles.count {
            let title = self.titles[index]
            let titleWidth = title.width(font: self.config.titleNormalFont)
            let itemLeft = CGFloat(index) * itemWidth + (itemWidth - titleWidth)/2 - 4
            let pointView = self.redPointViews[index]
            pointView.frame.origin = CGPoint(x: itemLeft, y: top)
            self.segmentTitleView.addSubview(pointView)
        }
        self.updateSegmentTitleViewRedPoint()
    }

    func updateSegmentTitleViewRedPoint() {
        guard let data = GXUserManager.shared.tabRedPointData else { return }
        for index in 0..<self.titles.count {
            let title = self.titles[index]
            let pointView = self.redPointViews[index]
            switch title {
            case "活动咨询":
                pointView.isHidden = !data.consultationRedPoint
            case "报名群":
                pointView.isHidden = !data.signRedPoint
            case "工作群":
                pointView.isHidden = !data.workRedPoint
            case "系统消息":
                pointView.isHidden = !data.systemMessageRedPoint
            default: break
            }
        }
    }

}

extension GXConversationListVC: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        self.segmentTitleView.setSegmentTitleView(selectIndex: page.selectedIndex, willSelectIndex: page.willSelectedIndex, progress: progress)
    }
}

extension GXConversationListVC: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: true)
    }
}
