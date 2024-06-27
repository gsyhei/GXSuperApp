//
//  GXHomeDetailViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/27.
//

import UIKit
import PromiseKit

class GXHomeDetailViewModel: GXBaseViewModel {
    /// 动态cell配置
    var cellIndexs: [Int] = []
    /// 站点信息
    var rowModel: GXStationConsumerRowsModel? {
        didSet {
            self.updateCellIndexs()
        }
    }
    /// 枪列表
    var ccRowsList: [GXConnectorConsumerRowsItem] = []
    /// 需要显示的时段
    var showPrices:[GXStationConsumerDetailPricesItem] = []
    /// 站点详情数据
    var detailData: GXStationConsumerDetailData? {
        didSet {
            self.updateShowPrices()
        }
    }
    
    /// 站点详情
    func requestStationConsumerDetail() -> Promise<GXStationConsumerDetailModel> {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.rowModel?.id
        let api = GXApi.normalApi(Api_station_consumer_detail, params, .get)
        return Promise { seal in
            GXNWProvider.gx_request(api, type: GXStationConsumerDetailModel.self, success: { model in
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
        params["stationId"] = self.rowModel?.id
        params["pageNum"] = 1 + (self.ccRowsList.count + PAGE_SIZE - 1)/PAGE_SIZE
        params["pageSize"] = PAGE_SIZE
        let api = GXApi.normalApi(Api_connector_consumer_list, params, .get)
        return Promise { seal in
            GXNWProvider.gx_request(api, type: GXConnectorConsumerListModel.self, success: { model in
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
    
}

extension GXHomeDetailViewModel {
    
    func updateCellIndexs() {
        guard let model = rowModel else { return }
        if model.occupyFlag == "YES" {
            self.cellIndexs = [0, 1, 2, 3, 4, 5, 6, 7, 8]
        }
        else {
            self.cellIndexs = [0, 1, 2, 3, 5, 6, 7, 8]
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
