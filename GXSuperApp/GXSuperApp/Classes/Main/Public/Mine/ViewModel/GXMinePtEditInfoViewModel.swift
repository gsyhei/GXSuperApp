//
//  GXMinePtEditInfoViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/2/3.
//

import UIKit
import GXConfigTableViewVC

class GXMinePtEditInfoViewModel: GXBaseViewModel {
    weak var nicknameModel: GXConfigTableRowDefaultModel?
    weak var userMaleModel: GXConfigTableRowDefaultModel?
    weak var birthdayModel: GXConfigTableRowDefaultModel?
    weak var personalModel: GXConfigTableRowCustomModel?

    func requestEditUserInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        if let nickName = self.nicknameModel?.detail.value {
            params["nickName"] = nickName
        }
        if let userMaleName = self.userMaleModel?.detail.value {
            if userMaleName == "男" {
                params["userMale"] = 1
            }
            else if userMaleName == "女" {
                params["userMale"] = 2
            }
            else {
                params["userMale"] = 0
            }
        }
        if let birthdayStr = self.birthdayModel?.detail.value {
            if let date = Date.date(dateString: birthdayStr, format: "yyyy年MM月dd日") {
                let birthday = date.string(format: "yyyyMMdd")
                params["birthday"] = birthday
            }
        }
        if let personalIntroduction = self.personalModel?.detail.value {
            params["personalIntroduction"] = personalIntroduction
        }
        let api = GXApi.normalApi(Api_User_EditUserInfo, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            self.updateUser(params: params)
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
    
    func updateUser(params: Dictionary<String, Any>) {
        GXUserManager.shared.user?.nickName = params["nickName"] as? String ?? ""
        GXUserManager.shared.user?.userMale = params["userMale"] as? Int ?? 0
        GXUserManager.shared.user?.birthday = params["birthday"] as? String ?? ""
        GXUserManager.shared.user?.personalIntroduction = params["personalIntroduction"] as? String ?? ""
    }
}
