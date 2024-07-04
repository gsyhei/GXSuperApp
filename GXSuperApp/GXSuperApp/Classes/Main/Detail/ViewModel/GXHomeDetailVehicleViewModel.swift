//
//  GXHomeDetailVehicleViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/3.
//

import UIKit
import PromiseKit

class GXHomeDetailVehicleViewModel: GXBaseViewModel {
    
    /// 车辆列表
    func requestVehicleConsumerList() -> Promise<GXVehicleConsumerListModel?> {
        let params: Dictionary<String, Any> = [:]
        let api = GXApi.normalApi(Api_vehicle_consumer_list, params, .get)
        return Promise { seal in
            guard GXUserManager.shared.isLogin else {
                seal.fulfill(nil); return
            }
            GXNWProvider.login_request(api, type: GXVehicleConsumerListModel.self, success: { model in
                GXUserManager.shared.vehicleList = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 删除车辆
    func requestVehicleConsumerDelete(indexPath: IndexPath) -> Promise<GXBaseModel?> {
        let model = GXUserManager.shared.vehicleList[indexPath.section]
        var params: Dictionary<String, Any> = [:]
        params["id"] = model.id
        let api = GXApi.normalApi(Api_vehicle_consumer_delete, params, .post)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXBaseModel.self, success: { model in
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }

}
