//
//  GXChargingFeeConfirmViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/5.
//

import UIKit
import PromiseKit

class GXChargingFeeConfirmViewModel: GXBaseViewModel {
    /// 扫码数据
    var scanData: GXConnectorConsumerScanData?
    /// 订单ID
    var orderId: Int = 0
    
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
                if GXUserManager.shared.selectedVehicle == nil {
                    GXUserManager.shared.selectedVehicle = model.data.first
                }
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 开始充电
    func requestOrderConsumerStart() -> Promise<GXOrderConsumerStartModel> {
        var params: Dictionary<String, Any> = [:]
        params["connectorId"] = self.scanData?.connectorId
        if let vehicle = GXUserManager.shared.selectedVehicle {
            params["carNumber"] = vehicle.state + vehicle.carNumber
        }
        let api = GXApi.normalApi(Api_order_consumer_start, params, .post)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXOrderConsumerStartModel.self, success: { model in
                self.orderId = model.data?.id ?? 0
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 充电桩的充电状态
    func requestChargingConsumerStatus() -> Promise<GXOrderConsumerStatusModel> {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.orderId
        let api = GXApi.normalApi(Api_order_consumer_status, params, .get)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXOrderConsumerStatusModel.self, success: { model in
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}
