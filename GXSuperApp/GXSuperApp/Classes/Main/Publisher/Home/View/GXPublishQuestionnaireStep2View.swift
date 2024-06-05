//
//  GXPublishQuestionnaireStep2View.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/19.
//

import UIKit
import RxCocoa
import RxSwift
import RxCocoaPlus
import XCGLogger
import Reusable
import MBProgressHUD

class GXPublishQuestionnaireStep2View: UIView {
    private var disposeBag = DisposeBag()
    var saveAction: GXActionBlockItem<GXQuestionairetopicsModel>?
    /// 添加选项
    @IBOutlet weak var addItemsView: GXAddItemsView!
    @IBOutlet weak var addItemsViewHLC: NSLayoutConstraint!
    /// 显示题目标题-题目index
    @IBOutlet weak var titleLabel: UILabel!
    /// 题目名称
    @IBOutlet weak var topicNameTV: GXTextView!
    @IBOutlet weak var topicNameNumLabel: UILabel!
    /// 选项填写说明
    @IBOutlet weak var topicDescTV: GXTextView!
    @IBOutlet weak var topicDescNumLabel: UILabel!
    /// 问卷题目选项-单选
    @IBOutlet weak var radioButton: UIButton!
    /// 问卷题目选项-多选
    @IBOutlet weak var checkButton: UIButton!
    /// 底部栏
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    weak var model: GXQuestionairetopicsModel!
    private var titleIndex: Int = 0

    class func createView(model: GXQuestionairetopicsModel, index: Int?) -> GXPublishQuestionnaireStep2View {
        return GXPublishQuestionnaireStep2View.xibView().then {
            $0.model = model
            $0.titleIndex = index ?? 0
            $0.updateInput()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.topLeft, .topRight], radius: 16.0)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.cancelButton.setBackgroundColor(.white, for: .normal)
        self.saveButton.setBackgroundColor(.gx_green, for: .normal)

        self.topicNameTV.placeholder = "题目名称"
        self.topicNameTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.topicNameTV.markedTextRange == nil else { return }
            guard var text = self.topicNameTV.text else { return }
            let maxCount: Int = 50
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.topicNameTV.text = text
            }
            self.topicNameNumLabel.text = "\(text.count)/\(maxCount)"
            self.topicNameNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        self.topicDescTV.placeholder = "选填，比如选项值为1-5，1是不满意，5是非常满意"
        self.topicDescTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.topicDescTV.markedTextRange == nil else { return }
            guard var text = self.topicDescTV.text else { return }
            let maxCount: Int = 100
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.topicDescTV.text = text
            }
            self.topicDescNumLabel.text = "\(text.count)/\(maxCount)"
            self.topicDescNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)

        self.addItemsView.updateAction = {[weak self] height in
            guard let `self` = self else { return }
            self.addItemsViewHLC.constant = height
        }
    }

    func updateInput() {
        self.titleLabel.text = "题目\(self.titleIndex + 1)"
        self.topicNameTV.text = self.model.topicTitle
        self.topicDescTV.text = self.model.topicDesc

        if let topicOptions = self.model.questionaireTopicOptions {
            var textArray: [BehaviorRelay<String?>] = []
            for option in topicOptions {
                textArray.append(BehaviorRelay<String?>(value: option.optionTitle))
            }
            self.addItemsView.textArray = textArray
        }
        else {
            let text1 = BehaviorRelay<String?>(value: nil)
            let text2 = BehaviorRelay<String?>(value: nil)
            let text3 = BehaviorRelay<String?>(value: nil)
            let text4 = BehaviorRelay<String?>(value: nil)
            self.addItemsView.textArray = [text1, text2, text3, text4]
        }
        self.setTopicType(type: self.model.topicType ?? 0)
    }

    // 单选/多选
    func setTopicType(type: Int) {
        if type == 2 {
            self.radioButton.isSelected = false
            self.checkButton.isSelected = true
            self.model.topicType = 2
        }
        else if type == 1 {
            self.radioButton.isSelected = true
            self.checkButton.isSelected = false
            self.model.topicType = 1
        }
        else {
            self.radioButton.isSelected = false
            self.checkButton.isSelected = false
            self.model.topicType = nil
        }
    }

    func updateModel() {
        self.model.topicTitle = self.topicNameTV.text
        self.model.topicDesc = self.topicDescTV.text

        var topicOptions: [GXQuestionairetopicoptionsModel] = []
        for text in self.addItemsView.textArray {
            let option = GXQuestionairetopicoptionsModel()
            option.optionTitle = text.value
            topicOptions.append(option)
        }
        self.model.questionaireTopicOptions = topicOptions
    }
}

extension GXPublishQuestionnaireStep2View {

    @IBAction func radioButtonClicked(_ sender: UIButton) {
        self.setTopicType(type: 1)
    }

    @IBAction func checkButtonClicked(_ sender: UIButton) {
        self.setTopicType(type: 2)
    }

    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.hide(animated: true)
    }

    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.hide(animated: true)
    }

    @IBAction func saveButtonClicked(_ sender: UIButton) {
        if self.topicNameTV.text?.count ?? 0 == 0 {
            GXToast.showError(text: "请输入题目名称！")
            return
        }
        if (self.model.topicType ?? 0) == 0 {
            GXToast.showError(text: "请选择题目类型，单选或多选！")
            return
        }
        if self.addItemsView.textArray.count < 2 {
            GXToast.showError(text: "至少要2个选项!")
            return
        }
        for text in self.addItemsView.textArray {
            if text.value?.count ?? 0 == 0 {
                GXToast.showError(text: "选项内容不完整!")
                return
            }
        }
        self.updateModel()
        self.saveAction?(self.model)
        self.hide(animated: true)
    }

}
