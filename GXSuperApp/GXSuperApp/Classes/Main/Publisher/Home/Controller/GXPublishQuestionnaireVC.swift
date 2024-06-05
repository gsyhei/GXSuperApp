//
//  GXPublishHomeVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/8.
//

import UIKit
import GXSegmentPageView

class GXPublishQuestionnaireVC: GXBaseViewController {
    @IBOutlet weak var segmentTitleView: GXSegmentTitleView!
    @IBOutlet weak var pageView: GXSegmentPageView!
    private var activityData: GXActivityBaseInfoData!

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
            $0.setTitle("添加问卷", for: .normal)
            $0.setTitleColor(.gx_black, for: .normal)
            $0.setTitleColor(.gx_lightGray, for: .highlighted)
            $0.titleLabel?.font = .gx_font(size: 15)
            $0.setImage(UIImage(named: "aw_add"), for: .normal)
            $0.addTarget(self, action: #selector(self.rightButtonItemTapped), for: .touchUpInside)
        }
    }()

    private lazy var childVCs: [UIViewController] = {
        var children: [UIViewController] = []
        children.append(GXPublishQuestionnaireListVC(activityData: self.activityData, shelfStatus: 1))
        children.append(GXPublishQuestionnaireListVC(activityData: self.activityData, shelfStatus: 0))
        children.append(GXPublishQuestionnaireListVC(activityData: self.activityData, shelfStatus: 2))
        return children
    }()

    class func createVC(activityData: GXActivityBaseInfoData) -> GXPublishQuestionnaireVC {
        return GXPublishQuestionnaireVC.xibViewController().then {
            $0.activityData = activityData
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.title = "问卷列表"
        self.gx_addBackBarButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.addButton)

        self.segmentTitleView.setupSegmentTitleView(config: self.config, titles: ["已上架", "已下架", "平台禁用"])
        self.segmentTitleView.delegate = self

        self.pageView.collectionView.isScrollEnabled = false
        self.pageView.collectionView.backgroundColor = .white
        self.pageView.setupSegmentPageView(parent: self, children: self.childVCs)
        self.pageView.delegate = self
    }
}

extension GXPublishQuestionnaireVC: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        self.segmentTitleView.setSegmentTitleView(selectIndex: page.selectedIndex, willSelectIndex: page.willSelectedIndex, progress: progress)
    }
}

extension GXPublishQuestionnaireVC: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: true)
    }
}

extension GXPublishQuestionnaireVC {

    @objc func rightButtonItemTapped() {
        self.showQuestOperation()
    }

    func showQuestOperation() {
        let pickerView: GXQuestPickerView = {
            return GXQuestPickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 360)
                $0.completion = {[weak self] model in
                    guard let `self` = self else { return }
                    if let data = model.data {
                        let vc = GXPublishQuestionnaireStep1VC.createVC(activityId: self.activityData.id, questionaireId: data.id, isCopy: true)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else {
                        let vc = GXPublishQuestionnaireStep1VC.createVC(activityId: self.activityData.id)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }()
        pickerView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
}
