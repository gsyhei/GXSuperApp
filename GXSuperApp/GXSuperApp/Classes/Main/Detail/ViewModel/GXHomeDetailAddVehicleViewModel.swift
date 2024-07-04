//
//  GXHomeDetailAddVehicleViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/3.
//

import UIKit
import RxRelay
import PromiseKit

class GXHomeDetailAddVehicleViewModel: GXBaseViewModel {
    /// 州代码
    var state = BehaviorRelay<String?>(value: GXUserManager.shared.paramsData?.states.first)
    /// 活动名称
    var carTailNumber = BehaviorRelay<String?>(value: nil)
    /// 修改车辆
    var vehicle: GXVehicleConsumerListItem? {
        didSet {
            guard let letvehicle = vehicle else { return }
            self.state.accept(letvehicle.state)
            self.carTailNumber.accept(letvehicle.carNumber)
        }
    }
    
    /// 添加/修改车辆
    func requestVehicleConsumerSave() -> Promise<(GXBaseModel?, Bool)> {
        var params: Dictionary<String, Any> = [:]
        if let vehicle = self.vehicle {
            params["id"] = vehicle.id
        } 
        params["state"] = self.state.value
        params["carNumber"] = self.carTailNumber.value

        let api = GXApi.normalApi(Api_vehicle_consumer_save, params, .post)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXBaseModel.self, success: { model in
                seal.fulfill((model, self.vehicle != nil))
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}
