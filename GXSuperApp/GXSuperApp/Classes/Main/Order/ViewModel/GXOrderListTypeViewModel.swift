//
//  GXOrderListTypeViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/9.
//

import UIKit
import PromiseKit
import XCGLogger

struct GXChargingOrderDetailCellModel {
    var item: GXChargingOrderDetailData
    var rowsIndexs: [Int]
    
    init(item: GXChargingOrderDetailData, rowsIndexs: [Int]) {
        self.item = item
        self.rowsIndexs = rowsIndexs
    }
}

class GXOrderListTypeViewModel: GXBaseViewModel {
    /// 订单状态；CHARGING：充电中，OCCUPY：占位中，TO_PAY：待支付，FINISHED：已完成
    var orderStatus: String? = nil
    /// 订单列表
    var cellList: [GXChargingOrderDetailCellModel] = []
    /// 站点充电价格
    var priceData: GXStationConsumerPriceData?
    
    /// 订单列表
    func requestOrderConsumerList(isRefresh: Bool) -> Promise<(GXOrderConsumerListModel, Bool)> {
        var params: Dictionary<String, Any> = [:]
        if let status = self.orderStatus {
            params["orderStatus"] = status
        }
        if isRefresh {
            params["pageNum"] = 1
        }
        else {
            params["pageNum"] = 1 + (self.cellList.count + PAGE_SIZE - 1)/PAGE_SIZE
        }
        params["pageSize"] = PAGE_SIZE
        let api = GXApi.normalApi(Api_order_consumer_list, params, .get)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXOrderConsumerListModel.self, success: { model in
                guard let data = model.data else {
                    seal.fulfill((model, false)); return
                }
                if isRefresh {
                    self.cellList = []
                    XCGLogger.info("isRefresh: \(isRefresh)")
                }
                self.updateDataSource(rows: data.rows)
                seal.fulfill((model, self.cellList.count >= data.total))
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 站点充电价格
    func requestStationConsumerPrice(stationId: Int?) -> Promise<GXStationConsumerPriceModel?> {
        var params: Dictionary<String, Any> = [:]
        params["id"] = stationId
        let api = GXApi.normalApi(Api_station_consumer_price, params, .get)
        return Promise { seal in
            if self.priceData != nil {
                seal.fulfill(nil); return
            }
            GXNWProvider.login_request(api, type: GXStationConsumerPriceModel.self, success: { model in
                self.priceData = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}

extension GXOrderListTypeViewModel {
    
    private func updateDataSource(rows: [GXChargingOrderDetailData]) {
        for item in rows {
            var rowsIndexs: [Int] = []
            /// 添加rows: 场站使用信息
            rowsIndexs.append(1)
            //"orderStatus" //订单状态；CHARGING：充电中，OCCUPY：占位中，TO_PAY：待支付，FINISHED：已完成支付
            switch item.orderStatus {
            case "CHARGING":
                /// 添加View
                break
            case "OCCUPY":
                /// 添加View
                break
            case "TO_PAY":
                /// 添加rows: Charging Bill
                rowsIndexs.append(2)
                /// 添加rows: 占位费单Idle Fee Bill
                if item.occupyFeeDetails.count > 0 {
                    rowsIndexs.append(3)
                }
                /// 添加rows: 充电总费用
                rowsIndexs.append(5)
                /// 添加More、Pay
            case "FINISHED":
                /// 添加rows: Charging Bill
                rowsIndexs.append(2)
                /// 添加rows: 占位费单Idle Fee Bill
                if item.occupyFeeDetails.count > 0 {
                    rowsIndexs.append(3)
                }
                /// 添加rows: 支付费用
                rowsIndexs.append(4)
                /// 添加More
            default: break
            }
            /// 添加rows: 底部操作按钮
            rowsIndexs.append(10)
            let cellModel = GXChargingOrderDetailCellModel(item: item, rowsIndexs: rowsIndexs)
            self.cellList.append(cellModel)
        }
    }
    
}
