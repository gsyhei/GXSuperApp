//
//  GXPublishQuestionnaireDetailVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/21.
//

import UIKit
import GXSegmentPageView
import MBProgressHUD

class GXPublishQuestionnaireDetailVC: GXBaseWarnViewController {
    @IBOutlet weak var segmentTitleView: GXSegmentTitleView!
    @IBOutlet weak var pageView: GXSegmentPageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topicCountLabel: UILabel!
    @IBOutlet weak var objectLabel: UILabel!
    @IBOutlet weak var signUpNumLabel: UILabel!

    var activityData: GXActivityBaseInfoData!
    var data: GXPublishQuestionaireDetailData!
    var reportData: GXQuestionaireReportData?

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
        children.append(GXPublishQuestDetailTopicVC.createVC(activityData: self.activityData, detailData: self.data))
        children.append(GXPublishQuestStatsVC(reportData: self.reportData))
        return children
    }()

    class func createVC(activityData: GXActivityBaseInfoData, detailData: GXPublishQuestionaireDetailData) -> GXPublishQuestionnaireDetailVC {
        return GXPublishQuestionnaireDetailVC.xibViewController().then {
            $0.activityData = activityData
            $0.data = detailData
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetQuestionaireReport()
    }

    override func setupViewController() {
        self.title = "问卷统计"
        self.gx_addBackBarButtonItem()

        self.segmentTitleView.setupSegmentTitleView(config: self.config, titles: ["问卷题目", "问卷统计"])
        self.segmentTitleView.delegate = self

        self.pageView.collectionView.isScrollEnabled = true
        self.pageView.collectionView.backgroundColor = .white
        self.pageView.setupSegmentPageView(parent: self, children: self.childVCs)
        self.pageView.delegate = self

        self.nameLabel.text = self.data?.questionaireName
        self.topicCountLabel.text = "\(self.data?.questionaireTopics?.count ?? 0)"
        self.nameLabel.text = self.data?.questionaireName
        if (self.data?.questionaireTarget ?? 1) == 2 {
            self.objectLabel.text = "APP全员"
        } else {
            self.objectLabel.text = "报名用户"
        }
        self.signUpNumLabel.text = "0人"

        if self.data.questionaireStatus == 5 {
            let text = "审核未通过\n原因：\(self.data.rejectReason ?? "")"
            self.gx_showWarning(text: text)
        }
        else {
            self.gx_hideWarning()
        }
    }

    func requestGetQuestionaireReport() {
        /// 获取问卷统计
        let params: [String : Any] = ["questionaireId": self.data?.id ?? 0]
        let api = GXApi.normalApi(Api_Quest_QuestionaireReport, params, .get)
        GXNWProvider.login_request(api, type: GXQuestionaireReportModel.self, success: {[weak self] model in
            self?.reportData = model.data
            self?.updateTopic()
        }, failure: {[weak self] error in
            GXToast.showError(error, to: self?.view)
        })
    }

    func updateTopic() {
        self.topicCountLabel.text = "\(self.reportData?.topicNum ?? 0)"
        self.signUpNumLabel.text = "\(self.reportData?.submitNum ?? 0)人"

        guard let vc = self.childVCs[0] as? GXPublishQuestDetailTopicVC else { return }
        vc.updateReportData(self.reportData)

        guard let vc = self.childVCs[1] as? GXPublishQuestStatsVC else { return }
        vc.updateReportData(self.reportData)
    }
}

extension GXPublishQuestionnaireDetailVC: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
        if index == 1 {
            guard let vc = self.childVCs[1] as? GXPublishQuestStatsVC else { return }
            vc.updateReportData(self.reportData)
        }
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        self.segmentTitleView.setSegmentTitleView(selectIndex: page.selectedIndex, willSelectIndex: page.willSelectedIndex, progress: progress)
    }
}

extension GXPublishQuestionnaireDetailVC: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: true)
    }
}
