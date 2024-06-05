//
//  GXMineSettingNotifiViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit

class GXMineSettingNotifiViewModel: GXBaseViewModel {
    var settingData: GXMessageSettingData?

    /// 通知详情
    func requestGetMessageSetting(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["targetType"] = GXUserManager.shared.roleType.rawValue
        let api = GXApi.normalApi(Api_Msgset_GetMessageSetting, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXMessageSettingModel.self, success: { model in
            self.settingData = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
    
    /// 通知设置
    func requestSetMessageSetting(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["targetType"] = GXUserManager.shared.roleType.rawValue
        params["bonusMessage"] = self.settingData?.bonusMessage
        params["chatConsultateMessage"] = self.settingData?.chatConsultateMessage
        params["chatGroupMessage"] = self.settingData?.chatGroupMessage
        params["questionaireMessage"] = self.settingData?.questionaireMessage
        params["reportMessage"] = self.settingData?.reportMessage
        let api = GXApi.normalApi(Api_Msgset_SetMessageSetting, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
