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
    func requestParamConsumer() -> Promise<GXParamConsumerModel> {
        let params: Dictionary<String, Any> = [:]
        let api = GXApi.normalApi(Api_param_consumer_detail, params, .get)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXParamConsumerModel.self, success: { model in
                GXUserManager.shared.paramConsumerData = model.data
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
                GXUserManager.shared.dictListAvailable = model.data
                GXUserManager.shared.showDictListAvailable = model.data.filter({ $0.homeFlag == GX_YES })
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
    
}
