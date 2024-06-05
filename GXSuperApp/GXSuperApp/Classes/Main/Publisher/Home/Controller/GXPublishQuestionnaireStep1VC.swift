//
//  GXPublishQuestionnaireStep1VC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/18.
//

import UIKit
import RxCocoa
import RxCocoaPlus
import MBProgressHUD
import HXPhotoPicker

class GXPublishQuestionnaireStep1VC: GXBaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    /// 问卷名称
    @IBOutlet weak var questionnaireNameTV: GXTextView!
    @IBOutlet weak var questionnaireNameNumLabel: UILabel!
    /// 问卷对象-报名用户
    @IBOutlet weak var signUserButton: UIButton!
    /// 问卷对象-App全员
    @IBOutlet weak var allUserButton: UIButton!
    /// 问卷说明
    @IBOutlet weak var questionnaireDescTV: GXTextView!
    @IBOutlet weak var questionnaireDescNumLabel: UILabel!
    /// 底部栏
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    private lazy var viewModel: GXPublishQuestionnaireStepViewModel = {
        return GXPublishQuestionnaireStepViewModel()
    }()

    class func createVC(activityId: Int, data: GXPublishQuestionaireDetailData? = nil, questionaireId: Int? = nil, isCopy: Bool = false) -> GXPublishQuestionnaireStep1VC {
        return GXPublishQuestionnaireStep1VC.xibViewController().then {
            $0.viewModel.activityId = activityId
            $0.viewModel.isCopy = isCopy
            if let data = data {
                $0.viewModel.questionaireId = data.id
                $0.viewModel.detailData = data
            }
            else if let questionaireId = questionaireId {
                $0.viewModel.questionaireId = questionaireId
            }
            $0.hidesBottomBarWhenPushed = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetQuestionaireDetail()
    }

    override func setupViewController() {
        if self.viewModel.questionaireId != nil && !self.viewModel.isCopy {
            self.title = "编辑问卷"
        } else {
            self.title = "新建问卷"
        }
        
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.saveButton.setBackgroundColor(.white, for: .normal)
        self.nextButton.setBackgroundColor(.gx_green, for: .normal)
        self.setQuestionaireTarget(type: self.viewModel.questionaireTarget)

        self.questionnaireNameTV.placeholder = "问卷名称"
        self.questionnaireNameTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.questionnaireNameTV.markedTextRange == nil else { return }
            guard var text = self.questionnaireNameTV.text else { return }
            let maxCount: Int = 50
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.questionnaireNameTV.text = text
            }
            self.questionnaireNameNumLabel.text = "\(text.count)/\(maxCount)"
            self.questionnaireNameNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        self.questionnaireDescTV.placeholder = "问卷说明"
        self.questionnaireDescTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.questionnaireDescTV.markedTextRange == nil else { return }
            guard var text = self.questionnaireDescTV.text else { return }
            let maxCount: Int = 500
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.questionnaireDescTV.text = text
            }
            self.questionnaireDescNumLabel.text = "\(text.count)/\(maxCount)"
            self.questionnaireDescNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        // Bind input
        (self.questionnaireNameTV.rx.textInput <-> self.viewModel.questionaireName).disposed(by: disposeBag)
        (self.questionnaireDescTV.rx.textInput <-> self.viewModel.questionaireDesc).disposed(by: disposeBag)
    }    

    func updateInput() {
        self.setQuestionaireTarget(type: self.viewModel.detailData?.questionaireTarget ?? 0)
    }
}

extension GXPublishQuestionnaireStep1VC {
    
    /// 问卷对象 1-活动 2-app全员
    func setQuestionaireTarget(type: Int) {
        if type == 2 {
            self.signUserButton.isSelected = false
            self.allUserButton.isSelected = true
            self.viewModel.questionaireTarget = 2
        }
        else if type == 1 {
            self.signUserButton.isSelected = true
            self.allUserButton.isSelected = false
            self.viewModel.questionaireTarget = 1
        }
        else {
            self.signUserButton.isSelected = false
            self.allUserButton.isSelected = false
            self.viewModel.questionaireTarget = 0
        }
    }

    func requestGetQuestionaireDetail() {
        guard (self.viewModel.questionaireId != nil) else { return }

        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetQuestionaireDetail(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.updateInput()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestSaveQuestionaireDraft() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestAllSaveQuestionaireDraft(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showSuccess(text: "保存成功", to: self?.view)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

}

extension GXPublishQuestionnaireStep1VC {

    @IBAction func signUserButtonClicked(_ sender: UIButton) {
        self.setQuestionaireTarget(type: 1)
    }

    @IBAction func allUserButtonClicked(_ sender: UIButton) {
        self.setQuestionaireTarget(type: 2)
    }

    @IBAction func saveButtonClicked(_ sender: UIButton) {
        if self.viewModel.questionaireName.value?.count == 0 {
            GXToast.showError(text: "请输入问卷名称！")
            return
        }
        self.requestSaveQuestionaireDraft()
    }

    @IBAction func nextButtonClicked(_ sender: UIButton) {
        if self.viewModel.questionaireName.value?.count == 0 {
            GXToast.showError(text: "请输入问卷名称！")
            return
        }
        if self.viewModel.questionaireTarget == 0 {
            GXToast.showError(text: "请选择问卷对象！")
            return
        }
        let vc = GXPublishQuestionnaireStep2VC.xibViewController().then {
            $0.viewModel = self.viewModel
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
