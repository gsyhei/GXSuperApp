//
//  GXQuestPickerView.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/1.
//

import UIKit
import XCGLogger
import MBProgressHUD

class GXQuestPickerModel: NSObject {
    var title: String = ""
    var data: GXPublishQuestionaireDetailData?
}

class GXQuestPickerView: UIView {
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var closeButton: UIButton!
    var completion: GXActionBlockItem<GXQuestPickerModel>?
    private var questList: [GXQuestPickerModel] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        self.closeButton.setBackgroundColor(.gx_green, for: .normal)
        self.requestGetMyQuestionaire()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.topLeft, .topRight], radius: 12.0)
    }

    @IBAction func okButtonClicked(_ sender: Any?) {
        let selectedIndex = self.timePicker.selectedRow(inComponent: 0)
        let selectedData = self.questList[selectedIndex]
        self.completion?(selectedData)
        self.hide(animated: true)
    }

    @IBAction func closeButtonClicked(_ sender: Any?) {
        self.hide(animated: true)
    }

    /// 获取我的问卷
    func requestGetMyQuestionaire() {
        MBProgressHUD.showLoading(to: self)
        let api = GXApi.normalApi(Api_Quest_GetMyQuestionaireList, [:], .get)
        GXNWProvider.login_request(api, type: GXMyQuestionaireModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self)
            self.questList.removeAll()
            let newItem: GXQuestPickerModel = GXQuestPickerModel()
            newItem.title = "全新问卷"
            self.questList.append(newItem)
            for dataItem in model.data {
                let item: GXQuestPickerModel = GXQuestPickerModel()
                item.title = dataItem.questionaireName ?? ""
                item.data = dataItem
                self.questList.append(item)
            }
            self.timePicker.reloadAllComponents()
        }) {[weak self] error in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self)
            GXToast.showError(error, to: self)
            self.questList.removeAll()
            let newItem: GXQuestPickerModel = GXQuestPickerModel()
            newItem.title = "全新问卷"
            self.questList.append(newItem)
            self.timePicker.reloadAllComponents()
        }
    }
}

extension GXQuestPickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.questList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let model = self.questList[row]
        return model.title
    }

}
