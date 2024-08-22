//
//  GXHomeDetailViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/27.
//

import UIKit
import PromiseKit

class GXHomeDetailViewModel: GXBaseViewModel {
    /// 场站Id
    var stationId: Int = 0
    /// 动态cell配置
    var cellIndexs: [Int] = []
    /// 枪列表
    var ccRowsList: [GXConnectorConsumerRowsItem] = []
    /// 需要显示的时段
    var showPrices:[GXStationConsumerDetailPricesItem] = []
    /// 站点详情数据
    var detailData: GXStationConsumerDetailData? {
        didSet {
            self.updateCellIndexs()
            self.updateShowPrices()
        }
    }
    
    /// 站点详情
    func requestStationConsumerDetail() -> Promise<GXStationConsumerDetailModel> {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.stationId
        let api = GXApi.normalApi(Api_station_consumer_detail, params, .get)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXStationConsumerDetailModel.self, success: { model in
                self.detailData = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 站点枪列表
    func requestConnectorConsumerList() -> Promise<(GXConnectorConsumerListModel, Bool)> {
        var params: Dictionary<String, Any> = [:]
        params["stationId"] = self.stationId
        params["pageNum"] = 1
        params["pageSize"] = 1000
        //        params["pageNum"] = 1 + (self.ccRowsList.count + PAGE_SIZE - 1)/PAGE_SIZE
        //        params["pageSize"] = PAGE_SIZE
        let api = GXApi.normalApi(Api_connector_consumer_list, params, .get)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXConnectorConsumerListModel.self, success: { model in
                if let list = model.data?.rows {
                    self.ccRowsList.append(contentsOf: list)
                }
                let isNoMore = (self.ccRowsList.count >= model.data?.total ?? 0)
                seal.fulfill((model, isNoMore))
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
    
    /// 收藏
    func requestFavoriteConsumerSave() -> Promise<Bool> {
        var params: Dictionary<String, Any> = [:]
        params["stationId"] = self.stationId
        let api = GXApi.normalApi(Api_favorite_consumer_save, params, .post)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXFavoriteConsumerSaveModel.self, success: { model in
                let isFavorite = model.data?.favoriteFlag ?? false
                self.detailData?.favoriteFlag = isFavorite ? GX_YES : GX_NO
                seal.fulfill(isFavorite)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}

extension GXHomeDetailViewModel {
    
    func updateCellIndexs() {
        guard let detail = self.detailData else { return }
        if detail.freeParking.isEmpty {
            self.cellIndexs = [0, 1, 2, 3, 8, 5, 6, 7]
        }
        else {
            self.cellIndexs = [0, 1, 2, 3, 8, 4, 5, 6, 7]
        }
    }
    
    func updateShowPrices() {
        guard let detail = self.detailData else { return }
        
        self.showPrices.removeAll()
        let currTimeIndex = detail.prices.firstIndex { item in
            return item.priceType == 1 || item.priceType == 3
        }
        let count = detail.prices.count
        if let currIndex = currTimeIndex {
            let beCount = min(count, 3)
            for index in 0..<beCount {
                let beIndex = (currIndex + index) % count
                let bePrice = detail.prices[beIndex]
                self.showPrices.append(bePrice)
            }
        }
    }
    
}
