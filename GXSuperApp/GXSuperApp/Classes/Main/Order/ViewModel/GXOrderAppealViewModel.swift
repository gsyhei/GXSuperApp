//
//  GXOrderAppealViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/11.
//

import UIKit
import PromiseKit
import HXPhotoPicker
import RxRelay

class GXOrderAppealViewModel: GXBaseViewModel {
    /// 订单详情model
    var detailCellModel: GXChargingOrderDetailCellModel?
    /// 申诉描述
    var descInput = BehaviorRelay<String?>(value: nil)
    /// 申诉图片-最大9张
    var images: [PhotoAsset] = []
    /// 选择的申诉类型
    var selectedAppeal: GXDictListAvailableData?
    
    /// 场站服务- 3：申诉类型
    func requestDictListAvailable() -> Promise<GXDictListAvailableModel?> {
        var params: Dictionary<String, Any> = [:]
        params["typeId"] = 3
        let api = GXApi.normalApi(Api_dict_list_available, params, .get)
        return Promise { seal in
            if GXUserManager.shared.appealTypeList.count > 0 {
                seal.fulfill(nil); return
            }
            GXNWProvider.login_request(api, type: GXDictListAvailableModel.self, success: { model in
                GXUserManager.shared.appealTypeList = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}
