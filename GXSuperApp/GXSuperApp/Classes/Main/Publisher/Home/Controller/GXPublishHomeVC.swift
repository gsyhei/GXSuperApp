//
//  GXPublishHomeVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/8.
//

import UIKit
import GXSegmentPageView

class GXPublishHomeVC: GXBaseWarnViewController {
    @IBOutlet weak var calendarDayView: GXHorizontalCalendarDayView!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var segmentTitleView: GXSegmentTitleView!
    @IBOutlet weak var pageView: GXSegmentPageView!

    private weak var calendarMenu: GXVerticalCalendarMenu?

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

    private lazy var viewModel: GXHorizontalCalendarDaysModel = {
        return GXHorizontalCalendarDaysModel(date: GXServiceManager.shared.systemDate, isPublish: true)
    }()

    private lazy var childVCs: [UIViewController] = {
        var children: [UIViewController] = []
        children.append(GXPublishHomeMPActivityVC(calendarModel: self.viewModel))
        children.append(GXPublishHomeMDActivityVC())
        children.append(GXPublishHomeMHActivityVC(calendarModel: self.viewModel))
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
            .notification(GX_NotifName_NetworkStatus)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.showNotReachableWarning()
            }).disposed(by: disposeBag)
    }

    override func setupViewController() {
        self.calendarDayView.bindViewModel(viewModel: self.viewModel)
        self.segmentTitleView.setupSegmentTitleView(config: self.config, titles: ["我发布的活动", "我的草稿", "我协助的活动"])
        self.segmentTitleView.delegate = self

        self.pageView.collectionView.isScrollEnabled = true
        self.pageView.collectionView.backgroundColor = .white
        self.pageView.setupSegmentPageView(parent: self, children: self.childVCs)
        self.pageView.delegate = self
    }

    func selectedToIndex(index: Int) {
        self.view.layoutIfNeeded()
        self.segmentTitleView.setSelectIndex(at: index)
        self.pageView.scrollToItem(to: index, animated: false)
    }

    func showNotReachableWarning() {
        if GXServiceManager.shared.networkStatus == .notReachable {
            self.gx_showWarning(text: "当前网络不可用，请检查您的网络设置",
                                topView: self.calendarButton,
                                constant: 16)
        } else {
            self.gx_hideWarning()
        }
    }
}

extension GXPublishHomeVC {
    @IBAction func calendarButtonClicked(_ sender: UIButton) {
        if let mpActivityVC = self.childVCs.first as? GXPublishHomeMPActivityVC {
            mpActivityVC.hideMenu()
        }
        if let letMenu = self.calendarMenu {
            letMenu.hide(animated: true)
            return
        }
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 460)
        let menu = GXVerticalCalendarMenu(frame: rect)
        menu.calendarDayView.bindViewModel(viewModel: self.viewModel)
        menu.show(to: self.contentView, style: .sheetTop)
        self.calendarMenu = menu
    }
    @IBAction func qrCodeButtonClicked(_ sender: UIButton) {
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

extension GXPublishHomeVC: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
        self.viewModel.currentPageIndex = index
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        self.segmentTitleView.setSegmentTitleView(selectIndex: page.selectedIndex, willSelectIndex: page.willSelectedIndex, progress: progress)
    }
}

extension GXPublishHomeVC: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: true)
    }
}
