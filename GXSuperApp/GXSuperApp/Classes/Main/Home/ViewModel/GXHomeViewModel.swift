//
//  GXHomeViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/26.
//

import UIKit
import PromiseKit

class GXHomeViewModel: GXBaseViewModel {
    /// 站点
    var stationConsumerList: [GXStationConsumerRowsModel] = []

    /// 系统配置
    func requestParamConsumer() -> Promise<GXParamConsumerData?> {
        let params: Dictionary<String, Any> = [:]
        let api = GXApi.normalApi(Api_param_consumer_detail, params, .get)
        return Promise { seal in
            if let paramsData = GXUserManager.shared.paramsData {
                seal.fulfill(paramsData); return
            }
            GXNWProvider.login_request(api, type: GXParamConsumerModel.self, success: { model in
                GXUserManager.shared.paramsData = model.data
                seal.fulfill(model.data)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 进行中订单
    func requestOrderConsumerDoing() -> Promise<GXOrderConsumerDoingModel?> {
        let params: Dictionary<String, Any> = [:]
        let api = GXApi.normalApi(Api_order_consumer_doing, params, .get)
        return Promise { seal in
            guard GXUserManager.shared.isLogin else {
                GXUserManager.shared.orderDoing = nil
                seal.fulfill(nil); return
            }
            GXNWProvider.login_request(api, type: GXOrderConsumerDoingModel.self, success: { model in
                GXUserManager.shared.orderDoing = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 场站服务-2：站点标签
    func requestDictListAvailable() -> Promise<GXDictListAvailableModel> {
        var params: Dictionary<String, Any> = [:]
        params["typeId"] = 2
        let api = GXApi.normalApi(Api_dict_list_available, params, .get)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXDictListAvailableModel.self, success: { model in
                GXUserManager.shared.availableList = model.data
                GXUserManager.shared.showAvailableList = model.data.filter({ $0.homeFlag == GX_YES })
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 站点查询
    func requestStationConsumerQuery() -> Promise<GXStationConsumerModel> {
        let params = GXUserManager.shared.filter.toJSON() ?? [:]
        let api = GXApi.normalApi(Api_station_consumer_query, params, .get)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXStationConsumerModel.self, success: { model in
                self.stationConsumerList = model.data?.rows ?? []
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
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
    
}
